# frozen_string_literal: true

module Presenters
  # class or null object which avoids .try(:attribute) || 'default'
  class Entreprise
    include SiretFormattable

    delegate :siret, to: :entreprise

    private

    attr_reader :entreprise

    def initialize(instance)
      @entreprise = instance
    end
  end
end
