class CraftField < ApplicationRecord
  has_many :crafts, dependent: :destroy, inverse_of: :craft_field
  has_many :detailed_crafts, through: :crafts

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
end
