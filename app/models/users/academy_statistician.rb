module Users
  class AcademyStatistician < Statistician
    METABASE_DASHBOARD_ID = 30

    belongs_to :academy

    validates :academy_id, presence: true

    def dashboard_name
      'Statistiques'
    end

    def academy_statistician? = true

    def presenter
      Presenters::PrefectureStatistician.new(self)
    end

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
        department: departments.map(&:name) || '',
        school_year: SchoolYear::Current.new.beginning_of_period.year
      )
    end

    def departments
      academy.departments
    end
  end
end
