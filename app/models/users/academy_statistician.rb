module Users
  class AcademyStatistician < Statistician

    METABASE_DASHBOARD_ID = 30

    belongs_to :academy

    validates :academy_id, presence: true
    
    def dashboard_name
      'Statistiques'
    end

    def academy_statistician? ; true end

    def presenter
      Presenters::PrefectureStatistician.new(self)
    end

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
        department: departments.map(&:code).join(',') || '',
        school_year: SchoolYear::Current.new.beginning_of_period.year
      )
    end

    def departments
      academy.departments
    end

    rails_admin do
      navigation_label "Référents"
      list do
        field :first_name do
          label 'Prénom'
        end
        field :last_name do
          label 'Nom'
        end
        field :email do
          label 'Email'
        end
        field :academy do
          label 'Académie'
          pretty_value { bindings[:object]&.academy&.name}
        end
        field :statistician_validation do
          label 'Validation'
        end
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
        field :academy do
          label 'Académie'
        end
        field :statistician_validation do
          label 'Validation'
        end
      end

      show do
        field :first_name
        field :last_name
        field :email
        field :academy do
          label 'Académie'
        end
        field :statistician_validation do
          label 'Validation'
        end
      end
    end
  end
end