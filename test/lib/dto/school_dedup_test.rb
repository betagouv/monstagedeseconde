# frozen_string_literal: true

require 'test_helper'
module Dto
  class SchoolDedupTest < ActiveSupport::TestCase
    setup do
      @code_uai = 'abs'
      @school_rep = create(:school, rep_kind: :rep, code_uai: @code_uai)
    end

    test '.dup? false' do
      duplicate = create(:school, rep_kind: :qpv_proche, code_uai: 'lol')
      dedup = SchoolDedup.new(school: duplicate)
      refute dedup.dup?
    end
  end
end
