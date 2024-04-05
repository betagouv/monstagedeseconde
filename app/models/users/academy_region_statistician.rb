module Users
  class AcademyRegionStatistician < Statistician

    METABASE_DASHBOARD_ID = 31

    belongs_to :academy_region

    validates :academy_region_id, presence: true

    
    def dashboard_name
      'Statistiques'
    end

    def academy_region_statistician? ; true end

    def presenter
      Presenters::PrefectureStatistician.new(self)
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
        field :academy_region do
          label 'Régon académique'
          pretty_value { bindings[:object]&.academy_region&.name}
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