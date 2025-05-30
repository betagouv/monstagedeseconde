# frozen_string_literal: true

module InternshipOffers
  class Api < InternshipOffer
    MAX_CALLS_PER_MINUTE = 100
    EMPLOYER_DESCRIPTION_MAX_SIZE = 275

    # TODO: set a constant here if possible
    def self.mandatory_seconde_weeks
      SchoolTrack::Seconde.both_weeks.map do |week|
        "#{week.year}-W#{week.number.to_s.rjust(2, '0')}"
      end
    end

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

    validates :remote_id, presence: true

    validates :zipcode, zipcode: { country_code: :fr }
    validates :remote_id, uniqueness: { scope: :employer_id }
    validates :permalink, presence: true,
                          format: { without: /.*(test|staging).*/i, message: 'Le lien ne doit pas renvoyer vers un environnement de test.' }
    validates :employer_description, presence: true, length: { maximum: EMPLOYER_DESCRIPTION_MAX_SIZE }

    scope :uncompleted_with_max_candidates, lambda {
      where('1=1')
    }

    scope :fulfilled, lambda {
      none
    }
    #   applications_ar = InternshipApplication.arel_table
    #   offers_ar       = InternshipOffer.arel_table

    #   joins(:internship_applications)
    #     .where(applications_ar[:aasm_state].in(%w[approved signed]))
    #     .select([offers_ar[:id], applications_ar[:id].count.as('applications_count'), offers_ar[:max_candidates], offers_ar[:max_students_per_group]])
    #     .group(offers_ar[:id])
    #     .having(applications_ar[:id].count.gteq(offers_ar[:max_candidates]))
    # }

    scope :uncompleted_with_max_candidates, lambda {
      all
      # offers_ar       = InternshipOffer.arel_table
      # full_offers_ids = InternshipOffers::Api.fulfilled.ids

      # where(offers_ar[:id].not_in(full_offers_ids))
    }

    def init
      self.is_public ||= false
      super
    end

    def formatted_coordinates
      {
        latitude: coordinates.latitude,
        longitude: coordinates.longitude
      }
    end

    def reset_publish_states
      publish! if may_publish? && published_at.present?
      unpublish! if may_unpublish? && published_at.nil?
    end

    def period
      case weeks
      when [SchoolTrack::Seconde.first_week]
        1
      when [SchoolTrack::Seconde.second_week]
        2
      else
        0
      end
    end

    def formatted_weeks
      weeks.map { |week| "#{week.year}-W#{week.number}" }
    end

    def formatted_grades
      grades.map(&:short_name).sort
    end

    def as_json(options = {})
      super(options.merge(
        only: %i[title
                 description
                 employer_name
                 employer_description
                 employer_website
                 street
                 zipcode
                 city
                 remote_id
                 permalink
                 sector_uuid
                 max_candidates
                 published_at
                 is_public],
        methods: [:formatted_coordinates]
      )).merge(
        weeks: formatted_weeks,
        grades: formatted_grades
      )
    end
  end
end
