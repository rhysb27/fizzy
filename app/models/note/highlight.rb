class Recipe::Highlight < ApplicationRecord
  belongs_to :account, default: -> { recipe.account }
  belongs_to :recipe, touch: true
end
