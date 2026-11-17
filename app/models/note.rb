class Note < ApplicationRecord
  include Accessible, Assignable, Attachments, Broadcastable, Closeable, Colored, Commentable,
    Entropic, Eventable, Exportable, Highlightable, Mentions, Multistep, Pinnable, # Readable
    Rejectable,
    #   , Searchable, Stallable, Statuses, Storage::Tracked, Taggable, Triageable, Watchable

  # TODO: Adapt or deprecate the following:
  include Promptable

  # TODO: Begin extracting Card behaviour to Note, THEN create Recipe.
end