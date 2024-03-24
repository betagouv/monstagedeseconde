# frozen_string_literal: true

module StatisticianDepartmentable
  extend ActiveSupport::Concern

  included do
    validates :department, presence: true
    
    def dashboard_name
      'Statistiques'
    end

    def department_name
      Department.find_by(code: department).try(:name)
    end

    def department_zipcode
      department
    end

    def destroy
      super
    end

    def employer_like? ; true end
  end
end
