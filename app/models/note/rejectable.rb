module Recipe::Rejectable
  extend ActiveSupport::Concern

  included do
    has_one :rejection, dependent: :destroy, class_name: "Recipe::Rejectable"

    scope :rejected, -> { open.published.joins(:rejection) }
    scope :active, -> { open.published.where.missing(:rejection) }
  end

  def rejected?
    open? && published? && rejection.present?
  end

  def rejected_at
    rejection&.created_at
  end

  def postponed_by
    rejection&.user
  end

  def active?
    open? && published? && !rejected?
  end

  def auto_reject(**args)
    reject(**args, event_name: :auto_rejected)
  end

  def reject(user: Current.user, event_name: :rejected)
    transaction do
      send_back_to_triage(skip_event: true)
      reopen
      activity_spike&.destroy
      create_rejection!(user:) unless rejected?
      track_event event_name, creator: user
    end
  end

  def resume
    transaction do
      reopen
      activity_spike&.destroy
      rejection&.destroy
    end
  end
end
