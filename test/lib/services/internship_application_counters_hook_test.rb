require 'test_helper'

module Services
  class InternshipApplicationCountersHookTest < ActiveSupport::TestCase
    test 'update_internship_offer_week_counters' do
      internship_application       = create(:weekly_internship_application)
      other_internship_application = create(:weekly_internship_application)

      assert_equal 1, internship_application.internship_offer.total_applications_count
      assert_equal 1, other_internship_application.internship_offer.total_applications_count
      refute internship_application.reload.approved?

      internship_application.employer_validate!
      internship_application.approve!
      assert_equal 1, internship_application.internship_offer.approved_applications_count
    end
  end
end
