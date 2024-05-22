class Craft < ApplicationRecord
  belongs_to :craft_field
  has_many :detailed_crafts, dependent: :destroy, inverse_of: :craft

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
end
