module RailsAdminInternshipOfferable
  extend ActiveSupport::Concern
  included do
    # ActiveAdmin index specifics
    rails_admin do
      weight 11
      navigation_label 'Offres'

      list do
        scopes %i[kept discarded]
        field :title
        field :employer
        field :period do
          def label = 'Période de stage'

          def pretty_value
            bindings[:object].current_period_label
          end
        end
        field :department
        field :zipcode
        field :employer_name
        field :group
        field :is_public
        field :created_at
      end

      show do
        exclude_fields :blocked_weeks_count,
                       :total_applications_count,
                       :approved_applications_count,
                       :total_male_applications_count,
                       :total_female_applications_count,
                       :submitted_applications_count,
                       :rejected_applications_count,
                       :tutor
        field :employer_email do
          def label
            "Email de l'employeur"
          end

          def pretty_value
            bindings[:object].employer.email
          end
        end
        field :employer
        field :internship_offer_area do
          label 'Espace'
        end
        field :organisation do
          label 'Groupe ou institution'
        end
        field :period do
          def label = 'Période de stage'

          def pretty_value
            bindings[:object].current_period_label
          end
        end
      end

      edit do
        field :title
        field :description
        field :sector
        field :period
        field :max_candidates
        field :tutor_name
        field :tutor_phone
        field :tutor_email
        field :tutor_role
        field :employer_website
        field :discarded_at
        field :employer_name
        field :is_public
        field :group
        field :employer_description
        field :published_at
        # field :school
        # field :first_monday
      end

      export do
        field :title
        field :description
        field :group
        field :max_candidates
        field :total_applications_count
        field :employer_name
        field :tutor_name
        field :tutor_phone
        field :tutor_email
        field :tutor_role
        field :street
        field :zipcode
        field :departement
        field :city
        field :sector_name
        field :is_public
        field :supplied_applications
        field :visible
        field :created_at
        field :updated_at
        field :period do
          def label = 'Période de stage'

          def pretty_value
            bindings[:object].current_period_label
          end
        end
      end
    end
  end
end
