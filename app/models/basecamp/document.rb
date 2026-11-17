class Basecamp::Document < ApplicationRecord
  include Recordable
  
  include RichText, PlainText

  rich_text_attribute :content
  plain_text_attribute :title

  encrypts :content

  def title
    super.presence || "Untitled"
  end

  def exportable_filename
    ActiveStorage::Filename.new("#{title.strip}.html")
  end

  def auto_position?
    true
  end

  def subscribable?
  end

  def exportable?
    true
  end

  def commentable?
    true
  end

  def backlinking?
    true
  end
end
