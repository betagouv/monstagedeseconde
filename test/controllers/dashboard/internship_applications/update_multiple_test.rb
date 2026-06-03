# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module InternshipApplications
    class UpdateMultipleTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers
      include TeamAndAreasHelper

      test 'employer can reject several of their own applications' do
        employer, internship_offer = create_employer_and_offer_2nde
        application_1 = create(:weekly_internship_application, :submitted, internship_offer:)
        application_2 = create(:weekly_internship_application, :submitted, internship_offer:)

        sign_in(employer)
        post dashboard_update_multiple_internship_applications_path,
             params: { ids: "#{application_1.id},#{application_2.id}",
                       transition: 'reject!',
                       rejection_message: 'Non retenu' }

        assert_redirected_to dashboard_candidatures_path
        assert application_1.reload.rejected?
        assert application_2.reload.rejected?
      end

      test "employer cannot transition another employer's application" do
        employer, internship_offer = create_employer_and_offer_2nde
        own_application = create(:weekly_internship_application, :submitted, internship_offer:)
        _other_employer, other_offer = create_employer_and_offer_2nde
        foreign_application = create(:weekly_internship_application, :submitted, internship_offer: other_offer)

        sign_in(employer)
        post dashboard_update_multiple_internship_applications_path,
             params: { ids: "#{own_application.id},#{foreign_application.id}",
                       transition: 'reject!',
                       rejection_message: 'Non retenu' }

        assert_redirected_to root_path
        assert own_application.reload.submitted?, 'own application must not change when batch is denied'
        assert foreign_application.reload.submitted?, "another employer's application must stay untouched"
      end
    end
  end
end
