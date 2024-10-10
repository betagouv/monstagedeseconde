# frozen_string_literal: true

module Users
  class PrefectureStatistician < Statistician
    include StatisticianDepartmentable

    METABASE_DASHBOARD_ID = 3

    def department_statistician? = true

    def department_name
      Department.find_by(code: department).try(:name)
    end

    def presenter
      Presenters::PrefectureStatistician.new(self)
    end
  end
end
