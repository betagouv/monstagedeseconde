# frozen_string_literal: true

require 'test_helper'
module Users
  class InternshipOccupationTest < ActiveSupport::TestCase
    test 'building works' do
      internship_occupation = build(:internship_occupation)
      assert internship_occupation.valid?
    end

    test 'creating works' do
      assert_difference 'InternshipOccupation.count', 1 do
        internship_occupation = create(:internship_occupation)
        assert internship_occupation.valid?
      end
    end
  end
end
