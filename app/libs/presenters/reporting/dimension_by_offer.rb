# frozen_string_literal: true

require 'forwardable'
module Presenters
  module Reporting
    class DimensionByOffer < BaseDimension
      ATTRS = %i[description
                 period
                 human_max_candidates
                 human_max_candidates_string
                 published_at
                 department
                 academy
                 permalink].freeze
      METHODS = %i[group_name
                   grades_as_string
                   human_is_public
                   sector_name
                   contact_name
                   contact_email
                   full_employer
                   full_address
                   full_school
                   full_year].freeze

      def self.metrics
        [].concat(ATTRS, METHODS)
      end

      delegate(*ATTRS, to: :instance)

      def self.dimension_name
        "Titre de l'offre"
      end

      def human_max_candidates
        instance.max_candidates
      end

      def period
        internship_offer = ::InternshipOffer.find(instance.id)
        Presenters::WeekList.new(weeks: internship_offer.weeks).str_weeks_display.map(&:strip).join("\n")
      end

      def human_max_candidates_string
        instance.max_candidates == 1 ? 'Individuel' : ' Collectif'
      end

      def human_is_public
        instance.is_public ? 'Public' : 'Privé'
      end

      def dimension
        instance.title
      end

      def sector_name
        instance.sector.name
      end

      def group_name
        instance.group.try(:name) || 'Indépendant'
      end

      def contact_name
        instance.employer.presenter.full_name
      end

      def contact_email
        instance.employer.email
      end

      def full_employer
        [instance.employer_name, instance.employer_website, instance.employer_description].compact.join("\n")
      end

      def full_address
        Address.new(instance:).to_s
      end

      def full_year
        'Non'
      end

      def full_school
        return nil unless instance.school

        [instance.school.name, "#{instance.school.city} – CP #{instance.school.zipcode}"].compact.join("\n")
      end

      def published_at
        return 'Masquée ou expirée ' if instance.published_at.nil?

        instance.published_at
      end

      def grades_as_string
        str_arr = []
        str_arr << "2de"  if instance.grades.include?(Grade.seconde)
        str_arr << "3eme" if instance.grades.include?(Grade.troisieme)
        str_arr << "4eme" if instance.grades.include?(Grade.quatrieme)
        str_arr.join(' - ')
      end

      # def weeks_list
      #   return [] unless instance.respond_to?(:weeks)

      #   instance.weeks.each_with_index.map do |week, i|
      #     "Du #{week.beginning_of_week} au #{week.end_of_week}"
      #   end
      # end

      def submitted_applications_count
        instance.stats.submitted_applications_count
      end

      def rejected_applications_count
        instance.stats.rejected_applications_count
      end

      def approved_applications_count
        instance.stats.approved_applications_count
      end

      def view_count
        instance.stats.view_count
      end
    end
  end
end
