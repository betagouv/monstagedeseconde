require 'test_helper'

module Dashboard::MultiStepper::MultiCorporations
  class CorporationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @employer = create(:employer)
      @multi_activity = create(:multi_activity, employer: @employer)
      @multi_coordinator = create(:multi_coordinator, multi_activity: @multi_activity)
      @multi_corporation = create(:multi_corporation, multi_coordinator: @multi_coordinator)
      # Stage partagé = exactement 2 structures : on repart d'une liste vide pour
      # contrôler le nombre de structures dans chaque test.
      @multi_corporation.corporations.destroy_all
      @sector = create(:sector)
      sign_in(@employer)
    end

    def valid_corporation_params(overrides = {})
      {
        corporation_name: 'Test Corp',
        corporation_address: '1 Rue de la Paix 75002 Paris',
        corporation_city: 'Paris',
        corporation_zipcode: '75002',
        corporation_street: '1 Rue de la Paix',
        city: 'Paris',
        zipcode: '75002',
        street: '1 Rue de la Paix',
        employer_name: 'John Doe',
        employer_role: 'Directeur',
        employer_email: 'john@test.com',
        tutor_name: 'Jane Doe',
        tutor_role_in_company: 'Manager',
        tutor_email: 'jane@test.com',
        tutor_phone: '0612345678',
        sector_id: @sector.id,
        siret: '12345678901234'
      }.merge(overrides)
    end

    test 'POST #create with valid address should geocode coordinates' do
      stub_request(:get, "https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=1%20Rue%20de%20la%20Paix%2075002%20Paris").
        to_return(status: 200, body: [{ lat: 48.869, lon: 2.332, display_name: '1 Rue de la Paix, Paris' }].to_json, headers: {})

      assert_difference('Corporation.count', 1) do
        post dashboard_multi_stepper_multi_corporation_corporations_path(@multi_corporation), params: {
          corporation: valid_corporation_params
        }
      end

      created_corporation = Corporation.last
      assert_not_nil created_corporation.internship_coordinates
      assert_in_delta 48.869, created_corporation.internship_coordinates.latitude, 0.001
      assert_in_delta 2.332, created_corporation.internship_coordinates.longitude, 0.001
    end

    test 'POST #create est bloqué quand les 2 structures sont déjà renseignées' do
      create(:corporation, multi_corporation: @multi_corporation, period: 1)
      create(:corporation, multi_corporation: @multi_corporation, period: 2)

      assert_predicate @multi_corporation.reload, :full?

      assert_no_difference('Corporation.count') do
        post dashboard_multi_stepper_multi_corporation_corporations_path(@multi_corporation),
             params: { corporation: valid_corporation_params(period: 1) },
             as: :turbo_stream
      end

      assert_match 'renseignées et validées', response.body
    end

    test 'POST #create persists the period' do
      post dashboard_multi_stepper_multi_corporation_corporations_path(@multi_corporation),
           params: { corporation: valid_corporation_params(period: 2, latitude: 48.85, longitude: 2.35) }

      assert_redirected_to new_dashboard_multi_stepper_multi_corporation_path(multi_coordinator_id: @multi_coordinator.id)
      assert_equal 2, Corporation.last.period
    end

    test 'POST #create (html) is blocked with an alert when already full' do
      create(:corporation, multi_corporation: @multi_corporation, period: 1)
      create(:corporation, multi_corporation: @multi_corporation, period: 2)

      assert_no_difference('Corporation.count') do
        post dashboard_multi_stepper_multi_corporation_corporations_path(@multi_corporation),
             params: { corporation: valid_corporation_params }
      end

      assert_redirected_to new_dashboard_multi_stepper_multi_corporation_path(multi_coordinator_id: @multi_coordinator.id)
      assert_equal 'Les 2 structures sont déjà renseignées.', flash[:alert]
    end

    test 'POST #create with a duplicate period is rejected with the validation message' do
      create(:corporation, multi_corporation: @multi_corporation, period: 1)

      assert_no_difference('Corporation.count') do
        post dashboard_multi_stepper_multi_corporation_corporations_path(@multi_corporation),
             params: { corporation: valid_corporation_params(period: 1) }
      end

      assert_redirected_to new_dashboard_multi_stepper_multi_corporation_path(multi_coordinator_id: @multi_coordinator.id)
      assert_match 'déjà couverte', flash[:alert]
    end

    test 'PATCH #update (html) updates the corporation' do
      corporation = create(:corporation, multi_corporation: @multi_corporation, period: 1)

      patch dashboard_multi_stepper_multi_corporation_corporation_path(@multi_corporation, corporation),
            params: { corporation: { corporation_name: 'Structure renommée' } }

      assert_redirected_to edit_dashboard_multi_stepper_multi_corporation_path(@multi_corporation)
      assert_equal 'Structure renommée', corporation.reload.corporation_name
    end

    test 'DELETE #destroy (html) removes the corporation and frees its period' do
      corporation = create(:corporation, multi_corporation: @multi_corporation, period: 1)

      assert_difference('Corporation.count', -1) do
        delete dashboard_multi_stepper_multi_corporation_corporation_path(@multi_corporation, corporation)
      end

      assert_redirected_to edit_dashboard_multi_stepper_multi_corporation_path(@multi_corporation)
      assert_equal 1, @multi_corporation.reload.next_available_period
    end

    test 'create is forbidden for an employer who is not the owner' do
      sign_out @employer
      sign_in create(:employer)

      assert_no_difference('Corporation.count') do
        post dashboard_multi_stepper_multi_corporation_corporations_path(@multi_corporation),
             params: { corporation: valid_corporation_params }
      end

      assert_redirected_to root_path
    end

    test 'create requires authentication' do
      sign_out @employer

      post dashboard_multi_stepper_multi_corporation_corporations_path(@multi_corporation),
           params: { corporation: valid_corporation_params }

      assert_redirected_to new_user_session_path
    end
  end
end

