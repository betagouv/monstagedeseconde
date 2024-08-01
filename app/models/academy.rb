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

  # TODO: change method name // remove if offer has department
  def self.lookup_by_zipcode(zipcode:)
    Department.where(name: Department.lookup_by_zipcode(zipcode:)).first.academy.name
  end

  def self.get_email_domain(academy)
    Academy.find_by(name: academy).email_domain
  end

  rails_admin do
    weight 16
    navigation_label 'Divers'

    list do
      field :name
      # field :email_domain
    end
    show do
      field :name
      # field :email_domain
    end
    edit do
      field :name
      # field :email_domain
    end
  end
end
