# frozen_string_literal: true

module Presenters
  # class or null object which avoids .try(:attribute) || 'default'
  class MultiCoordinator
    include SiretFormattable

    delegate :siret, to: :multi_coordinator

    private

    attr_reader :multi_coordinator

    def initialize(instance)
      @multi_coordinator = instance
    end
  end
end

