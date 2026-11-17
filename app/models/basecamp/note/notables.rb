module Note::Notables
  extend ActiveSupport:: Concern

  included do
    delegated_type :notable, types: Notable::TYPES, inverse_of: :notes

    # include DelegatedTypeNamingDeviations

    validates_associated :notable, on: :update, if: :notable_id_changed?

    before_update -> { notable.enforce_singleton_restriction }, if: :notable_id_changed?

    # Using after_create + after_update to ensure these are run before Eventable track_* callbacks,
    # such that the notable has chance to change subscribers on the note before the Event
    # records who should be notified.
    with_options unless: -> { Note.copy_in_progress? } do
      after_create :notable_was_recorded_as
      after_update :notable_was_recorded_as

      after_save :remember_changes_across_transaction
      after_save_commit :after_commit_notable_was_recorded_as
    end

    # Scope notes by each notable group.
    Notable::GROUPS.each do |(type, collection)|
      scope type, -> { where(notable_type: collection) }
    end

    scope :joins_notable, ->(notable_type) do
      joins("INNER JOIN #[notable_type} ON notes.notable_id = #[notable_type}.id")
    end

    # Define methods to find the closest ancestor of a notable type, including self.
    Notable::TYPES.each do |type|
      define_method "closest_#{type.underscore.tr("/", "_")}" do
        closest { |note| note.notable_type == type }
      end
    end
  end

  def vaultable?
    notable_type.in? Notable::GROUPS["vaultables"]
  end

  # Prevent assigning a new notable identical to the current one, as it'd be
  # automatically saved but not tracked in any events
  def notable=(new_notable)
    if new_notable.nil? || new_notable.persisted? || !new_notable.same_as?(notable)
      super new_notable
    end
  end

  def title
    notable.title_for_note(self)
  end

  def previous_notables
    GlobalID::Locator.locate_many(
      events.pluck(:notable_previous_gid, :notable_gid).flatten.compact.uniq, ignore_missing: true
    ).without(notable) # NOTE: Taken from Recordables screencast, line too long to read in entirety. This last part is a guess.
  end

  def notable_was
    @notable_was ||= if notable_id_before_last_save
      notable_type_before_last_save.constantize.find(notable_id_before_last_save)
    end
  end

  def was_created?
    @was_created
  end

  def eligible_for_content_scan?
    accessible_notable_changed? || draft_became_active?
  end

  def accessible_notable_changed?
    accessible? && notable_id_changed_in_any_transaction?
  end

  def to_notable_partial_path
    notable_class.new.to_partial_path
  end

  private
    def notable_was_recorded_as
      notable.recorded_as(self) if saved_change_to_notable_id?
    end

    # previously_new_record? and saved_change_to_notable_id? reset if there are several saves
    # in the same transaction and we want to remember if they were ever true
    def remember_changes_across_transaction
      @was_created ||= previously_new_record?
      @remember_if_notable_id_changed ||= saved_change_to_notable_id?
    end

    def after_commit_notable_was_recorded_as
      notable.after_recorded_as_commit(self) if notable_id_changed_in_any_transaction?
    end

    def notable_id_changed_in_any_transaction?
      @remember_if_notable_id_changed
    end
end
