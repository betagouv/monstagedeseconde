class AcademyRegion < ApplicationRecord
  has_many :academies
  has_many :departments, through: :academies
  has_many :academy_region_statisticians, class_name: 'Users::AcademyRegionStatistician', foreign_key: 'academy_region_id'

  rails_admin do
    weight 16
    navigation_label 'Divers'
    
  end
end
