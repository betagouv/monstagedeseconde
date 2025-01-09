# frozen_string_literal: true

module StepperProxy
  module HostingInfo
    extend ActiveSupport::Concern

    included do
      after_initialize :init

      belongs_to :school, optional: true, touch: true

      # Validations
      validates :max_candidates,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: InternshipOffer::MAX_CANDIDATES_HIGHEST }

      enum period: {
        full_time: 0,
        week_1: 1,
        week_2: 2
      }

      attribute :period, :integer, default: 0

      def self.current_period_labels
        SchoolTrack::Seconde.current_period_labels.values
      end

      def self.current_period_collection
        current_period_labels.each.with_index(0).map do |value, index|
          [value, index]
        end
      end

      def current_period_label
        HostingInfo.current_period_labels[period]
      end

      def is_individual?
        max_candidates == 1
      end

      def init
        self.max_candidates ||= 1
      end
    end
  end
end
