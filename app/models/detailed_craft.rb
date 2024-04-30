class DetailedCraft < ApplicationRecord
  belongs_to :craft
  has_many :coded_crafts, dependent: :destroy, inverse_of: :detailed_craft

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
end
