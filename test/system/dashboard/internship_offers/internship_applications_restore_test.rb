require 'application_system_test_case'

module Dashboard::InternshipOffers
  class InternshipApplicationsRestoreTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

    test 'employer sees restore button when application is rejected and spots are available' do
      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(
        :weekly_internship_application,
        :rejected,
        internship_offer:
      )

      sign_in(employer)
      visit dashboard_internship_offer_internship_application_path(
        internship_offer,
        uuid: internship_application.uuid
      )

      assert internship_offer.has_spots_left?
      find('button', text: 'Restaurer ma candidature')
    end

    test 'employer sees warning when application is rejected but no spots left' do
      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(
        :weekly_internship_application,
        :rejected,
        internship_offer:
      )
      other_student = create(:student)
      create(
        :weekly_internship_application,
        :approved,
        internship_offer:,
        student: other_student
      )

      sign_in(employer)
      visit dashboard_internship_offer_internship_application_path(
        internship_offer,
        uuid: internship_application.uuid
      )

      refute internship_offer.reload.has_spots_left?
      assert_no_selector 'button', text: 'Restaurer ma candidature'
      assert_text 'Vous pourrez restaurer cette candidature après avoir'
    end
  end
end
