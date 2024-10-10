module Users
  class AcademyRegionStatistician < Statistician
    METABASE_DASHBOARD_ID = 30

    belongs_to :academy_region

    validates :academy_region_id, presence: true

    def dashboard_name
      'Statistiques'
    end

    def academy_region_statistician? = true

    def departments
      academy_region.departments
    end

    def presenter
      Presenters::PrefectureStatistician.new(self)
    end

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
        department: departments.map(&:name) || '',
        school_year: SchoolYear::Current.new.beginning_of_period.year
      )
    end
  end
end
