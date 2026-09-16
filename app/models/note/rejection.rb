class Recipe::Rejection < ApplicationRecord
  belongs_to :account, default: -> { recipe.account }
  belongs_to :recipe, class_name: "::Recipe", touch: true
  belongs_to :user, optional: true
end
