class CodedCraft < ApplicationRecord
  belongs_to :detailed_craft
  has_many :coded_craft_fields, dependent: :destroy, inverse_of: :coded_craft

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :ogr_code, presence: true, length: { maximum: 10 }, uniqueness: true
end
