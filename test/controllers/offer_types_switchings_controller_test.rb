require 'test_helper'

class Dashboard::OfferTypesSwitchingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @employer = create(:employer)
    sign_in @employer
  end

  test "should get new" do
    get dashboard_choix_type_offre_path
    assert_response :success
  end

  test "should redirect to stepper for 'for_my_company'" do
    post dashboard_validation_choix_type_offre_path, params: { offer_type_choice: 'for_my_company' }
    assert_redirected_to new_dashboard_stepper_internship_occupation_path
  end

  test "should redirect to stepper for 'for_another_company'" do
    post dashboard_validation_choix_type_offre_path, params: { offer_type_choice: 'for_another_company' }
    assert_redirected_to new_dashboard_stepper_internship_occupation_path
  end

  test "should redirect to multi stepper for 'for_multiple_companies'" do
    post dashboard_validation_choix_type_offre_path, params: { offer_type_choice: 'for_multiple_companies' }
    assert_redirected_to new_dashboard_multi_stepper_multi_activity_path
  end

  test "should render new with alert for invalid choice" do
    post dashboard_validation_choix_type_offre_path, params: { offer_type_choice: 'invalid_choice' }
    assert_response :unprocessable_entity
    assert_select '.alert', /Veuillez sélectionner un type d'offre./
  end

  test "should require authentication" do
    sign_out @employer
    get dashboard_validation_choix_type_offre_path
    assert_redirected_to new_user_session_path
  end
end