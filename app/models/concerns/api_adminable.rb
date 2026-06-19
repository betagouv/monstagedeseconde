module ApiAdminable
  extend ActiveSupport::Concern

  included do
    rails_admin do
      weight 13
      navigation_label 'Offres'

      configure :created_at, :datetime do
        date_format 'BUGGY'
      end

      list do
        scopes %i[kept discarded]

        field :title
        field :department
        field :zipcode
        field :employer_name
        field :is_public
        field :created_at
      end

      edit do
        field :title
        field :description
        field :employer_name
        field :employer_description
        field :employer_website
        field :street
        field :zipcode
        field :city
        field :sector
        field :remote_id
        field :permalink
        field :max_candidates
        field :is_public
      end

      export do
        field :title
        field :employer_name
        field :zipcode
        field :city
        field :max_candidates
        field :total_applications_count
        field :approved_applications_count
        field :rejected_applications_count
        field :is_public
      end

      show do
      end
    end
  end
end