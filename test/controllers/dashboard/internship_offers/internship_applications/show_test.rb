# frozen_string_literal: true

require "test_helper"

module InternshipApplications
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "GET #show as employer" do
      internship_application = create(:weekly_internship_application, :submitted)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                 uuid: internship_application.uuid)

      assert_response :success
      internship_application.reload
      assert_equal "read_by_employer", internship_application.aasm_state
    end

    test "GET #show redirects to root_path when not logged in" do
      internship_application = create(:weekly_internship_application)
      get dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                 uuid: internship_application.uuid)
      assert_redirected_to user_session_path
    end

    test "GET #show redirects to root_path when token is wrong" do
      internship_application = create(:weekly_internship_application)
      get dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                 uuid: internship_application.uuid,
                                                                 token: "abc")
      assert_redirected_to root_path
    end

    test 'GET #show warns and hides transfer when offer has no spots left' do
      offer = create(:weekly_internship_offer_2nde, max_candidates: 1)
      pending = create(:weekly_internship_application, :submitted, internship_offer: offer)
      create(:weekly_internship_application, :approved, internship_offer: offer)

      sign_in(offer.employer)
      get dashboard_internship_offer_internship_application_path(offer, uuid: pending.uuid)

      assert_response :success
      assert_select '.fr-alert.fr-alert--warning', /Cette offre n'a plus de places disponibles/
      assert_select '.fr-alert.fr-alert--warning a',
                    text: 'Augmentez le nombre de places',
                    href: edit_dashboard_internship_offer_path(offer, anchor: 'max_candidates_fields')
      assert_select 'a', text: 'Transférer', count: 0
      assert_select 'button', text: 'Accepter', count: 0
    end
  end
end
