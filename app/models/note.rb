class Note < ApplicationRecord
  # BEGIN Basecamp ---------------------------------------------------
  include Tree, Status
  include Readable, Bookmarkable, Incineratable # Depends on Status
  include AdditionSubscribable, Attachables, AutoArchiving, Backlinkable, Backlinking, Boostable,
    Cancelable, Recording::Categories, Chartable, ClientVisibility, Colored, Commentable, Copyable,
    Dropboxed, Due, Exportable, Indexed, InternallyAccessible, HillChartable, Kanbanable, Lockable,
    Mentions, Movable, Notify, Pinnable, Preloadable, Printable, Publishable, Recordables, Replyable,
    Respondable, SchedulablePosting, Subscribable, Threadable, Visibility, TrackStorage,
    TimelineOrdered, Timesheetable
  include Remindable, Pausable, Participatable, Publishing, Categorizable, OrderedChildren,
    PositionedChildren, Recurrable, Repeatable

  include Eventable   # Depends on Recordables
  include Assignable  # Depends on Subscribable
  include Positioned  # Depends on Status, PositionedChildren
  include Dockable    # Depends on Status
  include Completable # Depends on Positioned include PinnedChildren # Depends on Pinnable

  # END Basecamp ---------------------------------------------------

  # BEGIN Fizzy ----------------------------------------------------
  include Accessible, Assignable, Attachments, Broadcastable, Closeable, Colored, Commentable,
    Entropic, Eventable, Exportable, Highlightable, Mentions, Multistep, Pinnable, # Readable
    Rejectable,
    #   , Searchable, Stallable, Statuses, Storage::Tracked, Taggable, Triageable, Watchable

  # TODO: Adapt or deprecate the following:
  include Promptable
  # END Fizzy ------------------------------------------------------

  belongs_to :bucket, touch: true
  belongs_to :creator, class_name: "Person", default: -> { Current.person }, inverse_of: false

  scope :chronologically, -> { order :created_at, :id }
  scope :reverse_chronologically, -> { order created_at: :desc, recordable_id: :desc, id: :desc }

  delegate :account, to: :bucket

  def self.creators_in(recordings)
    Person.where(id: recordings.pluck (:creator_id))
  end

  def reachable_people(include_admissible_people: false)
    bucket.reachable_people(include_clients: visible_to_clients?, include_admissible_people:)
  end

  # Duck type with objects that have a Recording. E.g., boostable.recording when boostable is a Recording.
  def recording
    self
  end

  def memorizable?
    recordable.memorizable?
  end
end
