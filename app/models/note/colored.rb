# Mapped intent: unclear, but still a useful concept.
module Recipe::Colored
  extend ActiveSupport::Concern

  def color
    column&.color || Column::Colored::DEFAULT_COLOR
  end
end
