# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class EntreprisesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      Sector.create(name: 'Fonction publique')
    end

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
              contact_phone: '0123456789',
              is_public: false,
              sector_id: sector.id,
              workspace_conditions: 'Environnement de travail',
              workspace_accessibility: 'Accessibilité du poste',
              code_ape: '99.XXX'
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
      assert_equal 'Environnement de travail', entreprise.workspace_conditions
      assert_equal 'Accessibilité du poste', entreprise.workspace_accessibility
      assert_equal '99.XXX', entreprise.code_ape
    end

    test 'create with manual siret and short adress completes coordinates with geocoder and redirects to new planning' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sector = create(:sector)
      sign_in(employer)

         geocoder_response = {
        status: 200,
        body:{
          "lat": 48,
          "lon": 2
        }.to_json
      }
      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=75001%20Paris').to_return(geocoder_response)
      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=75001,%20France').to_return(geocoder_response)
      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=75001%20Paris,%20,%2075001,%20France').to_return(geocoder_response)

      assert_difference('Entreprise.count') do
        post(
          dashboard_stepper_entreprises_path(internship_occupation_id: internship_occupation.id),
          params: {
            entreprise: {
              internship_occupation_id: internship_occupation.id,
              siret: '12345678901234',
              employer_name: 'Test',
              entreprise_chosen_full_address: '75001 Paris',
              contact_phone: '0123456789',
              is_public: false,
              sector_id: sector.id,
              workspace_conditions: 'Environnement de travail',
              workspace_accessibility: 'Accessibilité du poste',
              code_ape: '99.XXX'
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
      assert_equal '75001 Paris', entreprise.entreprise_full_address
      assert_nil entreprise.entreprise_chosen_full_address
      assert_equal false, entreprise.is_public
      assert_equal sector.id, entreprise.sector_id
      assert_equal 48, entreprise.entreprise_coordinates.latitude
      assert_equal 2, entreprise.entreprise_coordinates.longitude
      assert entreprise.updated_entreprise_full_address
      assert_equal 'Environnement de travail', entreprise.workspace_conditions
      assert_equal 'Accessibilité du poste', entreprise.workspace_accessibility
      assert_equal '99.XXX', entreprise.code_ape
    end

    test 'POST create with manual siret and wrong adress renders new form with errors' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sector = create(:sector)
      sign_in(employer)

      geocoder_response = {
        status: 200,
        body:{
          "error": "wrong address"
        }.to_json
      }
      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=xxxx').to_return(geocoder_response)


      assert_no_difference('Entreprise.count') do
        post(
          dashboard_stepper_entreprises_path(internship_occupation_id: internship_occupation.id),
          params: {
            entreprise: {
              internship_occupation_id: internship_occupation.id,
              siret: '12345678901234',
              employer_name: 'Test',
              entreprise_chosen_full_address: 'xxxx',
              contact_phone: '0123456789',
              is_public: false,
              sector_id: sector.id,
              workspace_conditions: 'Environnement de travail',
              workspace_accessibility: 'Accessibilité du poste',
              code_ape: '99.XXX'
            }
          }
        )
        assert_response :bad_request
        assert_match(/Adresse non trouvée/, response.body)
      end
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

    # Tests de cohérence is_public / sector / group_id

    test 'POST create public entreprise without group_id fails' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sign_in(employer)

      assert_no_difference('Entreprise.count') do
        post(
          dashboard_stepper_entreprises_path(internship_occupation_id: internship_occupation.id),
          params: {
            entreprise: {
              internship_occupation_id: internship_occupation.id,
              siret: '12345678901234',
              employer_name: 'Ministère Test',
              entreprise_full_address: '1 rue de Paris 75001 Paris',
              entreprise_chosen_full_address: '1 rue de Paris 75001 Paris',
              entreprise_coordinates_longitude: '2.35',
              entreprise_coordinates_latitude: '48.85',
              contact_phone: '0123456789',
              is_public: true,
              group_id: nil,
              workspace_conditions: 'Environnement de travail',
              workspace_accessibility: 'Accessibilité du poste'
            }
          }
        )
        assert_response :bad_request
      end
    end

    test 'POST create public entreprise with group_id succeeds' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      group = create(:group, is_public: true)
      sign_in(employer)

      assert_difference('Entreprise.count', 1) do
        post(
          dashboard_stepper_entreprises_path(internship_occupation_id: internship_occupation.id),
          params: {
            entreprise: {
              internship_occupation_id: internship_occupation.id,
              siret: '12345678901234',
              employer_name: 'Ministère Test',
              entreprise_full_address: '1 rue de Paris 75001 Paris',
              entreprise_chosen_full_address: '1 rue de Paris 75001 Paris',
              entreprise_coordinates_longitude: '2.35',
              entreprise_coordinates_latitude: '48.85',
              contact_phone: '0123456789',
              is_public: true,
              group_id: group.id,
              workspace_conditions: 'Environnement de travail',
              workspace_accessibility: 'Accessibilité du poste'
            }
          }
        )
        assert_redirected_to new_dashboard_stepper_planning_path(entreprise_id: Entreprise.last.id)
      end

      entreprise = Entreprise.last
      assert entreprise.is_public
      assert_equal group.id, entreprise.group_id
      assert_equal 'Fonction publique', entreprise.sector.name
    end

    test 'POST create private entreprise with group_id fails' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sector = create(:sector, name: 'Secteur privé')
      group = create(:group, is_public: true)
      sign_in(employer)

      assert_no_difference('Entreprise.count') do
        post(
          dashboard_stepper_entreprises_path(internship_occupation_id: internship_occupation.id),
          params: {
            entreprise: {
              internship_occupation_id: internship_occupation.id,
              siret: '12345678901234',
              employer_name: 'Entreprise Privée',
              entreprise_full_address: '1 rue de Paris 75001 Paris',
              entreprise_chosen_full_address: '1 rue de Paris 75001 Paris',
              entreprise_coordinates_longitude: '2.35',
              entreprise_coordinates_latitude: '48.85',
              contact_phone: '0123456789',
              is_public: false,
              group_id: group.id,
              sector_id: sector.id,
              workspace_conditions: 'Environnement de travail',
              workspace_accessibility: 'Accessibilité du poste'
            }
          }
        )
        assert_response :bad_request
      end
    end

    test 'POST create private entreprise with sector Fonction publique fails' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      fonction_publique_sector = Sector.find_or_create_by!(name: 'Fonction publique')
      sign_in(employer)

      assert_no_difference('Entreprise.count') do
        post(
          dashboard_stepper_entreprises_path(internship_occupation_id: internship_occupation.id),
          params: {
            entreprise: {
              internship_occupation_id: internship_occupation.id,
              siret: '12345678901234',
              employer_name: 'Entreprise Privée',
              entreprise_full_address: '1 rue de Paris 75001 Paris',
              entreprise_chosen_full_address: '1 rue de Paris 75001 Paris',
              entreprise_coordinates_longitude: '2.35',
              entreprise_coordinates_latitude: '48.85',
              contact_phone: '0123456789',
              is_public: false,
              group_id: nil,
              sector_id: fonction_publique_sector.id,
              workspace_conditions: 'Environnement de travail',
              workspace_accessibility: 'Accessibilité du poste'
            }
          }
        )
        assert_response :bad_request
      end
    end

    test 'POST create private entreprise without group_id and valid sector succeeds' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sector = create(:sector, name: 'Informatique')
      sign_in(employer)

      assert_difference('Entreprise.count', 1) do
        post(
          dashboard_stepper_entreprises_path(internship_occupation_id: internship_occupation.id),
          params: {
            entreprise: {
              internship_occupation_id: internship_occupation.id,
              siret: '12345678901234',
              employer_name: 'Entreprise Privée',
              entreprise_full_address: '1 rue de Paris 75001 Paris',
              entreprise_chosen_full_address: '1 rue de Paris 75001 Paris',
              entreprise_coordinates_longitude: '2.35',
              entreprise_coordinates_latitude: '48.85',
              contact_phone: '0123456789',
              is_public: false,
              group_id: nil,
              sector_id: sector.id,
              workspace_conditions: 'Environnement de travail',
              workspace_accessibility: 'Accessibilité du poste'
            }
          }
        )
        assert_redirected_to new_dashboard_stepper_planning_path(entreprise_id: Entreprise.last.id)
      end

      entreprise = Entreprise.last
      refute entreprise.is_public
      assert_nil entreprise.group_id
      assert_equal sector.id, entreprise.sector_id
    end

    test 'PATCH update from private to public without group_id fails' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sector = create(:sector, name: 'Informatique')
      entreprise = create(:entreprise, internship_occupation:, is_public: false, group: nil, sector:)
      sign_in(employer)

      patch(
        dashboard_stepper_entreprise_path(entreprise),
        params: {
          entreprise: {
            is_public: true,
            group_id: nil
          }
        }
      )
      assert_response :bad_request
      entreprise.reload
      refute entreprise.is_public
    end

    test 'PATCH update from private to public with group_id succeeds' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sector = create(:sector, name: 'Informatique')
      group = create(:group, is_public: true)
      entreprise = create(:entreprise, internship_occupation:, is_public: false, group: nil, sector:)
      sign_in(employer)

      patch(
        dashboard_stepper_entreprise_path(entreprise),
        params: {
          entreprise: {
            is_public: true,
            group_id: group.id,
            entreprise_chosen_full_address: entreprise.entreprise_full_address,
            entreprise_coordinates_longitude: entreprise.entreprise_coordinates.longitude,
            entreprise_coordinates_latitude: entreprise.entreprise_coordinates.latitude
          }
        }
      )
      assert_response :redirect
      entreprise.reload
      assert entreprise.is_public
      assert_equal group.id, entreprise.group_id
      assert_equal 'Fonction publique', entreprise.sector.name
    end
  end
end
