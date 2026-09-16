module Notable
  extend ActiveSupport:: Concern

  include HumanName, Positioned, NotableName, Scheduled, Singleton, Titled
  include ToolName # depends on HumanName

  TYPES = [
    'Recipe'
    # Attachment
    # AutolinkedImage
    # Bulletin::Message Bulletin::Link
    # Chat::Transcript Chat::Lines::Code Chat::Lines::Integration Chat::Lines::Play Chat::Lines::Reimaging Chat::Lines::Renaming Chat::Lines::RichTex
    # Client::Board Client::Introduction Client::Correspondence Client::Forward Client::Reply Client::Approval Client::Approval::Response
    # CloudFile
    # Comment
    # Dock
    # Document
    # Door
    # Embed
    # Gauge Gauge::Needle
    # GoogleDocument
    # Hill::Dot Hill::Version
    # Inbox Inbox::Forward Inbox::Reply
    # Journal Journal::Entry
    # Kanban::Board Kanban::Card Kanban::Column Kanban::DoneColumn Kanban::NotNowColumn Kanban::OnHold Kanban::Step
    # Message Message::Board
    # Onboarding::Message
    # Printout
    # Questionnaire Question Question::Answer
    # Relay
    # Schedule Schedule::Entry Schedule::Entry::Occurrence
    # Timeline
    # Timesheet Timesheet::Entry
    # Todoset Todolist Todo
    # Upload
    # Vault
  ]

  GROUPS = {}

  included do
    has_many :notes, as: :notable, autosave: false
  end

  # Returns a new, unsaved copy of the notable after changing the given attributes.
  def changing(attributes)
    dup.tap { |copy| copy.assign_attributes(attributes) }
  end

  # Overwrite to perform notable-specific actions after note. For example, Comment
  # uses this to compose its title based on the parent of its note. Note that this is
  # not called during note copies.
  def recorded_as(note)
  end

  # Same as recorded_as but runs after the transaction ends
  def after_recorded_as_commit(note)
  end

  # Overwrite to perform notable-specific actions after a note changes its status
  def status_changed(note)
  end

  # Overwrite to perform notable-specific actions after a note changes its assignees
  def assignees_changed(note)
  end

  # Overwrite to perform notable-specific actions after a note is filed
  def filed_as(filing)
  end

  # Overwrite to control whether the creator of a subscribable note should be auto-subscribed.
  def auto_subscribable?
    subscribable?
  end

  # Allow notables to specify whether they support subscriptions.
  def subscribable?
    false
  end

  # Allow notables, like Dock or Transcript, that aren't meant to be searchable themselves be
  # excluded from indexes, and other notables like Vaults, decide based on the note provided.
  def searchable?(note)
    true
  end

  # Allow notables to specify whether they support reminders.
  def remindable?
    false
  end

  # Allow notables to specify whether a specific reminder is still needed for the recipient
  def reminder_needed?(reminder)
    true
  end

  # Allow notables to specify whether they can be replied to.
  def replyable?
    false
  end

  # Allow notables to specify whether they support respondents.
  def respondable?
    false
  end

  def backlinking?
    false
  end

  def commentable?
    false
  end

  def exportable?
    false
  end

  def copyable?
    true
  end

  def movable?
    copyable?
  end

  def recurrable?
    false
  end

  def recurring?
    false
  end

  def repeatable?
    false
  end

  def repeating?
    false
  end

  def hill_chartable?
    false
  end

  def trashable_by_anyone?
    true
  end

  def byte_size
    0
  end

  def occurrence_notable_class
    raise NotImplementedError
  end

  def occurrence?
    false
  end

  def invalidates_exports?
    exportable?
  end

  def categories_container?
    false
  end

  def changes_client_visibility?
    false
  end

  def same_as?(notable)
    self.class == notable.class && same_attributes_as?(notable)
  end

  def events
    Event.where(notable_gid: to_gid.to_s)
  end

  def all_notes_deleted?
    notes.all?(&:deleted?) && events.all? { |e| e.note&.deleted? }
  end

  def memorizable?
    true
  end

  private
    def same_attributes_as?(notable, except: %w[ id ])
      attributes.except(*except) == notable.attributes.except(*except)
    end
end
