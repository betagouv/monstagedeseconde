class Academy < ApplicationRecord
  belongs_to :academy_region
  has_many :departments
  has_many :statisticians, class_name: 'Users::AcademyStatistician'

  def self.to_select(only: nil)
    Academy.all.map(&:name).sort
  end

  def self.departments_by_name(academy_name:)
    Academy.find_by(name: academy_name).departements
  end

  def self.academy_name_by_zipcode(zipcode:)
    Department.find_by(name: Department.lookup_by_zipcode(zipcode:))
              .academy
              .name
  end

  def self.get_email_domain(academy)
    Academy.find_by(name: academy).email_domain
  end
end
