# frozen_string_literal: true

module StatisticianDepartmentable
  extend ActiveSupport::Concern

  included do
    # belongs_to :department, optional: true
    #TODO Change after data migration 
    validates :department, presence: true
    
    def dashboard_name
      'Statistiques'
    end

    def department_name
      Department.find_by(code: department).try(:name)
    end

    def department_zipcode
      department.try(:zipcode)
    end

    def destroy
      super
    end

    def employer_like? ; true end
  end
end
