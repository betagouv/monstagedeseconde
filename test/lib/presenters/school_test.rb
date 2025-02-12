# frozen_string_literal: true

require 'test_helper'

module Presenters
  class SchoolTest < ActiveSupport::TestCase
    setup do
      @school = build(:school, school_type: :lycee, name: 'Lycée evariste Gallois')  # @school = build(:school, name: 'Lycée evariste Gallois')
      @school_2 = build(:school, school_type: :lycee, name: 'evariste Gallois')      # @school_manager = Users::SchoolManagement.new(role: :school_manager)
    end

    test '#agreement_address' do
      assert_equal 'Lycée evariste Gallois - Paris - 75015', School.new(@school).select_text_method
      assert_equal 'Lycée evariste Gallois - Paris - 75015', School.new(@school).agreement_address
      assert_equal 'Lycée evariste Gallois - Paris - 75015', School.new(@school_2).agreement_address
    end
  end
end
