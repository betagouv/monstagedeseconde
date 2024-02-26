# frozen_string_literal: true

module StepperProxy
  module HostingInfo
    extend ActiveSupport::Concern

    included do
      after_initialize :init

      # Validations
      validates :max_candidates,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: InternshipOffer::MAX_CANDIDATES_HIGHEST }
      validates :max_students_per_group,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: :max_candidates ,
                                message: "Le nombre maximal d'élèves par groupe ne peut pas dépasser le nombre maximal d'élèves attendus dans l'année" }

      enum period: {
        full_time: 0,
        week_1: 1,
        week_2: 2
      }

      attribute :period, :integer, default: 0

      def period_label
        InternshipOffer::PERIOD_LABELS.values[period]
      end

      def self.period_collection
        InternshipOffer::PERIOD_LABELS.values.each.with_index(0).map do |value, index| 
          [value, index]
        end
      end

      def is_individual?
        max_students_per_group == 1
      end

      def init
        self.max_candidates ||= 1
        self.max_students_per_group ||= 1
      end
    end
  end
end
