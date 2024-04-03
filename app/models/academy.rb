class Academy < ApplicationRecord
  belongs_to :academy_region
  has_many :departements, dependent: :destroy
end