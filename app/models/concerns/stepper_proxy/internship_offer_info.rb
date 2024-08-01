# frozen_string_literal: true

module StepperProxy
  module InternshipOfferInfo
    extend ActiveSupport::Concern

    included do
      attr_accessor :republish, :user_update

      # Validations as they should be for new and older offers
      validates :title, presence: true, length: { maximum: InternshipOffer::TITLE_MAX_CHAR_COUNT }

      validates :description, presence: true,
                              length: { maximum: InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT }

      # Relations
      belongs_to :sector

      def self.period_labels(school_year:)
        ::SchoolTrack::Seconde::PERIOD_COLLECTION[school_year]
      end

      def self.current_period_labels
        period_labels(school_year: SchoolYear::Current.new.end_of_period.year)
      end
    end
  end
end
