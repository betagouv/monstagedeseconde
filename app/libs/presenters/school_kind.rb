# frozen_string_literal: true

module Presenters
  class SchoolKind
    def to_s
      desc = '?'
      desc = 'REP+' if rep_kind == 'rep_plus'
      desc = 'REP' if rep_kind == 'rep'
      return desc unless qpv

      desc == '?' ? 'QPV' : "#{desc} (QPV)"
    end

    private

    attr_reader :rep_kind, :qpv

    def initialize(rep_kind:, qpv:)
      @rep_kind = rep_kind
      @qpv = qpv
    end
  end
end
