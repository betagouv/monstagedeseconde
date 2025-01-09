# frozen_string_literal: true

module Presenters
  # class or null object which avoids .try(:attribute) || 'default'
  class Entreprise
    delegate :siret, to: :entreprise

    def formal_siret
      return 'N/A' unless siret.present?

      siret.gsub(/(\d{3})(\d{3})(\d{3})(\d{5})/, '\1 \2 \3 \4')
    end

    private

    attr_reader :entreprise

    def initialize(instance)
      @entreprise = instance
    end
  end
end
