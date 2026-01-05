# frozen_string_literal: true

module Presenters
  # class or null object which avoids .try(:attribute) || 'default'
  class MultiCoordinator
    delegate :siret, to: :multi_coordinator

    def formal_siret
      return 'N/A' unless siret.present?

      siret.gsub(/(\d{3})(\d{3})(\d{3})(\d{5})/, '\1 \2 \3 \4')
    end

    private

    attr_reader :multi_coordinator

    def initialize(instance)
      @multi_coordinator = instance
    end
  end
end

