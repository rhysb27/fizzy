module Recipe::Highlightable
  extend ActiveSupport::Concern

  included do
    has_one :goldness, dependent: :destroy, class_name: "Recipe::Goldness"
    # has_one :highlight, dependent: :destroy, class_name: "Recipe::Highlight"
    
    scope :golden, -> { joins(:goldness) }
    # scope :highlighted, -> { joins(:highlight) }

    scope :with_golden_first, -> { left_outer_joins(:goldness).prepend_order("recipe_goldnesses.id IS NULL").preload(:goldness) }
    # scope :with_highlighted_first, -> { left_outer_joins(:highlight).prepend_order("recipe_highlight.id IS NULL").preload(:highlight) }
  end

  def golden? # highlighted?
    goldness.present? # highlight.present?
  end

  def gild # highlight!
    create_goldness! unless golden? # create_highlight! unless highlighted?
  end

  def ungild # unhighlight
    goldness&.destroy # highlight&.destroy
  end
end
