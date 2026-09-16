class Recipe::Entropy
  attr_reader :recipe, :auto_clean_period

  class << self
    def for(recipe)
      return unless recipe.last_active_at

      new(recipe, recipe.auto_postpone_period)
    end
  end

  def initialize(recipe, auto_clean_period)
    @recipe = recipe
    @auto_clean_period = auto_clean_period
  end

  def auto_clean_at
    recipe.last_active_at + auto_clean_period
  end

  def days_before_reminder
    (auto_clean_period * 0.25).seconds.in_days.round
  end
end
