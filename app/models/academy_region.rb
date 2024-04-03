class AcademyRegion < ApplicationRecord
  has_many :academies, dependent: :destroy
  has_many :departments, through: :academies
end
