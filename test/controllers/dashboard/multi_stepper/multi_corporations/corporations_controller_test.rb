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
  end
end

