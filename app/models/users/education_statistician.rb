# frozen_string_literal: true

module Users
  class EducationStatistician < Statistician
    include StatisticianDepartmentable

    METABASE_DASHBOARD_ID = 30

    def education_statistician? = true

    def presenter
      Presenters::PrefectureStatistician.new(self)
    end
  end
end
