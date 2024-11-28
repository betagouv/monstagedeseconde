# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class EntreprisesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET new not logged redirects to sign in' do
      get new_dashboard_stepper_entreprise_path
      assert_redirected_to user_session_path
    end

    test 'GET #new as employer show valid form' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sign_in(employer)
      get new_dashboard_stepper_entreprise_path(internship_occupation_id: internship_occupation.id)

      assert_response :success
    end

    test 'POST create redirects to new planning' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sector = create(:sector)
      sign_in(employer)
      assert_difference('Entreprise.count') do
        post(
          dashboard_stepper_entreprises_path(internship_occupation_id: internship_occupation.id),
          params: {
            entreprise: {
              internship_occupation_id: internship_occupation.id,
              siret: '12345678901234',
              employer_name: 'Test',
              entreprise_full_address: 'Test in Pariso',
              entreprise_chosen_full_address: 'Testo in Paris',
              entreprise_coordinates_longitude: '2.35',
              entreprise_coordinates_latitude: '48.85',
              is_public: false,
              sector_id: sector.id
            }
          }
        )
        assert_redirected_to new_dashboard_stepper_planning_path(
          entreprise_id: Entreprise.last.id
        )
        assert_equal "Les informations de l'entreprise ont bien été enregistrées", flash[:notice]
      end

      entreprise = Entreprise.last
      assert_equal '12345678901234', entreprise.siret
      assert_equal 'Test', entreprise.employer_name
      assert_equal 'Testo in Paris', entreprise.entreprise_full_address
      assert_nil entreprise.entreprise_chosen_full_address
      assert_equal false, entreprise.is_public
      assert_equal sector.id, entreprise.sector_id
      assert_equal 2.35, entreprise.entreprise_coordinates.longitude
      assert_equal 48.85, entreprise.entreprise_coordinates.latitude
      assert entreprise.updated_entreprise_full_address
    end

    test 'POST create with faulty payload fails gracefully' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sector = create(:sector)
      sign_in(employer)
      assert_no_difference('Entreprise.count') do
        post(
          dashboard_stepper_entreprises_path(internship_occupation_id: internship_occupation.id),
          params: {
            entreprise: {
              'internship_occupation_id' => internship_occupation.id,
              'siret' => '12345678901234',
              'employer_name' => 'Test',
              'entreprise_full_address' => 'Test',
              'entreprise_chosen_full_address' => 'Testo',
              'entreprise_coordinates_longitude' => '2.35',
              'entreprise_coordinates_latitude' => '48.85',
              'is_public' => 'true',
              'sector_id' => sector.id
            }
          }
        )
        assert_response :bad_request
      end
    end
  end
end
