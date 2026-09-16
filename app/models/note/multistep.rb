module Recipe::Multistep
  extend ActiveSupport::Concern

  included do
    has_many :steps, dependent: :destroy
  end
end
