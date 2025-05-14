module Users
  class AcademyRegionStatistician < Statistician
    include Signatorable

    METABASE_DASHBOARD_ID = 30

    belongs_to :academy_region

    validates :academy_region_id, presence: true

    def dashboard_name = 'Statistiques'
    def academy_region_statistician? = true
    def departments = academy_region.departments
    def presenter = Presenters::PrefectureStatistician.new(self)

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
        department: departments.map(&:name) || '',
        school_year: SchoolYear::Current.new.beginning_of_period.year
      )
    end

    rails_admin do
      navigation_label 'Référents'
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
        field :academy_region do
          label 'Régon académique'
          pretty_value { bindings[:object]&.academy_region&.name }
        end
        field :statistician_validation do
          label 'Validation'
        end
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
        field :academy_region do
          label 'Région académique'
        end
        field :statistician_validation do
          label 'Validation'
        end
        field :agreement_signatorable do
          label 'Signataire des conventions'
          help 'Si le V est coché en vert, le signataire doit signer TOUTES les conventions'
        end
      end

      show do
        field :first_name
        field :last_name
        field :email
        # field :academy_region do
        #   label 'Région académique'
        # end
        field :statistician_validation do
          label 'Validation'
        end
      end
    end
  end
end
