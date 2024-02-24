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

      PERIOD_LABELS = {
        full_time: "2 semaines - du 17 au 28 juin 2024",
        week_1: "1 semaine - du 17 au 21 juin 2024",
        week_2: "1 semaine - du 24 au 28 juin 2024"
      }

      def period_label
        PERIOD_LABELS.values[period]
      end

      def self.period_collection
        PERIOD_LABELS.values.each_with_index.map { |value, index| [value, index] }
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
