# frozen_string_literal: true

require 'test_helper'

module Dashboard::MultiStepper
  class MultiCoordinatorsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @employer = create(:employer)
      @multi_activity = create(:multi_activity, employer: @employer)
      @multi_coordinator = create(:multi_coordinator, multi_activity: @multi_activity)
      @sector = create(:sector)
    end

    test 'GET #new should display the form' do
      sign_in @employer
      get new_dashboard_multi_stepper_multi_coordinator_path(multi_activity_id: @multi_activity.id)
      assert_response :success
      assert_select 'form'
      assert_select 'h1', text: /Déposer une offre de stage pour 2 structures/
    end

    test 'GET #new should require authentication' do
      get new_dashboard_multi_stepper_multi_coordinator_path(multi_activity_id: @multi_activity.id)
      assert_redirected_to new_user_session_path
    end

    test 'GET #new should require authorization' do
      other_employer = create(:employer)
      sign_in other_employer
      get new_dashboard_multi_stepper_multi_coordinator_path(multi_activity_id: @multi_activity.id)
      assert_redirected_to root_path
    end

    test 'POST #create should create a new coordinator with valid params' do
      sign_in @employer
      
      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=16%20BOULEVARD%20DES%20ITALIENS%2075009%20PARIS')
        .to_return(
          status: 200,
          body: [{
            address: {
              road: 'BOULEVARD DES ITALIENS',
              postcode: '75009',
              city: 'PARIS',
              country: 'France'
            },
            lat: '48.8718',
            lon: '2.3399',
            name: 'PARIS'
          }].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      assert_difference('MultiCoordinator.count', 1) do
        post dashboard_multi_stepper_multi_coordinators_path,
             params: {
               multi_coordinator: {
                 siret: '66204244900014',
                 employer_name: 'BNP PARIBAS',
                 employer_chosen_name: 'BNP PARIBAS',
                 employer_address: '16 BOULEVARD DES ITALIENS 75009 PARIS',
                 employer_chosen_address: '16 BOULEVARD DES ITALIENS 75009 PARIS',
                 city: 'PARIS',
                 zipcode: '75009',
                 street: '16 BOULEVARD DES ITALIENS',
                 phone: '0653615361',
                 sector_id: @sector.id,
                 multi_activity_id: @multi_activity.id
               }
             }
      end
      assert_redirected_to edit_dashboard_multi_stepper_multi_corporation_path(MultiCorporation.last)
      follow_redirect!
      # TO DO fix this test
      # assert_select 'div.fr-alert', text: /Les informations du coordinateur ont bien été enregistrées/
    end

    test 'POST #create should not create with invalid params' do
      sign_in @employer
      assert_no_difference('MultiCoordinator.count') do
        post dashboard_multi_stepper_multi_coordinators_path,
             params: {
               multi_coordinator: {
                 employer_chosen_name: '',
                 employer_chosen_address: '',
                 city: '',
                 zipcode: '',
                 street: '',
                 phone: '',
                 multi_activity_id: @multi_activity.id
               }
             }
      end
      assert_response :bad_request
    end

    test 'GET #edit should display the edit form' do
      sign_in @employer
      get edit_dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator)
      assert_response :success
      assert_select 'form'
    end

    test 'GET #edit coordinateur privé : le bloc Type d\'employeur public est masqué au chargement' do
      sign_in @employer
      refute @multi_coordinator.is_public

      get edit_dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator)

      assert_response :success
      assert_select '#ministry-block.fr-hidden'
    end

    test 'GET #edit coordinateur public : le bloc Type d\'employeur public est visible' do
      sign_in @employer
      group = create(:group, is_public: true)
      @multi_coordinator.update!(is_public: true, group: group)

      get edit_dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator)

      assert_response :success
      assert_select '#ministry-block'
      assert_select '#ministry-block.fr-hidden', count: 0
    end

    test 'GET #edit should require authentication' do
      get edit_dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator)
      assert_redirected_to new_user_session_path
    end

    test 'GET #edit should require authorization' do
      other_employer = create(:employer)
      sign_in other_employer
      get edit_dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator)
      assert_redirected_to root_path
    end

    test 'PATCH #update should update coordinator with valid params' do
      sign_in @employer
      
      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=Updated%20Address')
        .to_return(
          status: 200,
          body: [{
            address: {
              road: 'Rue de la République',
              postcode: '69001',
              city: 'Lyon',
              country: 'France'
            },
            lat: '45.764043',
            lon: '4.835659',
            name: 'Lyon'
          }].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      patch dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator),
            params: {
              multi_coordinator: {
                employer_chosen_name: 'Updated Name',
                employer_chosen_address: 'Updated Address',
                city: 'LYON',
                zipcode: '69001',
                street: 'Updated Street',
                phone: '0612345678',
                sector_id: @sector.id
              }
            }
      multi_corporation = MultiCorporation.find_by(multi_coordinator: @multi_coordinator)
      assert_redirected_to edit_dashboard_multi_stepper_multi_corporation_path(multi_corporation)
      @multi_coordinator.reload
      assert_equal 'Updated Name', @multi_coordinator.employer_chosen_name
      assert_equal 'Updated Address', @multi_coordinator.employer_chosen_address
    end

    test 'PATCH #update should not update with invalid params' do
      sign_in @employer
      original_name = @multi_coordinator.employer_chosen_name
      patch dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator),
            params: {
              multi_coordinator: {
                employer_chosen_name: '',
                employer_chosen_address: '',
                city: '',
                zipcode: '',
                street: '',
                phone: ''
              }
            }
      assert_response :bad_request
      @multi_coordinator.reload
      assert_equal original_name, @multi_coordinator.employer_chosen_name
    end

    test 'PATCH #update should require authentication' do
      patch dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator),
            params: {
              multi_coordinator: {
                employer_chosen_name: 'Updated Name'
              }
            }
      assert_redirected_to new_user_session_path
    end

    test 'PATCH #update should require authorization' do
      other_employer = create(:employer)
      sign_in other_employer
      patch dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator),
            params: {
              multi_coordinator: {
                employer_chosen_name: 'Updated Name'
              }
            }
      assert_redirected_to root_path
    end

    test 'POST #create should set employer_chosen_name from employer_name if not provided' do
      sign_in @employer
      
      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=16%20BOULEVARD%20DES%20ITALIENS%2075009%20PARIS')
        .to_return(
          status: 200,
          body: [{
            address: {
              road: 'BOULEVARD DES ITALIENS',
              postcode: '75009',
              city: 'PARIS',
              country: 'France'
            },
            lat: '48.8718',
            lon: '2.3399',
            name: 'PARIS'
          }].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      post dashboard_multi_stepper_multi_coordinators_path,
           params: {
             multi_coordinator: {
               siret: '66204244900014',
               employer_name: 'BNP PARIBAS',
               employer_address: '16 BOULEVARD DES ITALIENS 75009 PARIS',
               employer_chosen_address: '16 BOULEVARD DES ITALIENS 75009 PARIS',
               city: 'PARIS',
               zipcode: '75009',
               street: '16 BOULEVARD DES ITALIENS',
               phone: '0653615361',
               sector_id: @sector.id,
               multi_activity_id: @multi_activity.id
             }
           }
      coordinator = MultiCoordinator.last
      assert_equal 'BNP PARIBAS', coordinator.employer_chosen_name
    end

    test 'POST #create should validate phone format' do
      sign_in @employer
      
      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=Test%20Address')
        .to_return(
          status: 200,
          body: [].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      assert_no_difference('MultiCoordinator.count') do
        post dashboard_multi_stepper_multi_coordinators_path,
             params: {
               multi_coordinator: {
                 employer_chosen_name: 'Test',
                 employer_chosen_address: 'Test Address',
                 city: 'PARIS',
                 zipcode: '75009',
                 street: 'Test Street',
                 phone: '123', # Invalid phone
                 multi_activity_id: @multi_activity.id
               }
             }
      end
      assert_response :bad_request
    end

    test 'POST #create should validate siret length' do
      sign_in @employer
      
      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=Test%20Address')
        .to_return(
          status: 200,
          body: [].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      assert_no_difference('MultiCoordinator.count') do
        post dashboard_multi_stepper_multi_coordinators_path,
             params: {
               multi_coordinator: {
                 siret: '123', # Invalid siret length
                 employer_chosen_name: 'Test',
                 employer_chosen_address: 'Test Address',
                 city: 'PARIS',
                 zipcode: '75009',
                 street: 'Test Street',
                 phone: '0653615361',
                 multi_activity_id: @multi_activity.id
               }
             }
      end
      assert_response :bad_request
    end

    test 'POST #create public coordinator with a group (ministère) succeeds' do
      sign_in @employer
      group = create(:group, is_public: true)

      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=16%20BOULEVARD%20DES%20ITALIENS%2075009%20PARIS')
        .to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      assert_difference('MultiCoordinator.count', 1) do
        post dashboard_multi_stepper_multi_coordinators_path,
             params: {
               multi_coordinator: {
                 siret: '66204244900014',
                 employer_chosen_name: 'BNP PARIBAS',
                 employer_chosen_address: '16 BOULEVARD DES ITALIENS 75009 PARIS',
                 city: 'PARIS',
                 zipcode: '75009',
                 street: '16 BOULEVARD DES ITALIENS',
                 phone: '0653615361',
                 sector_id: @sector.id,
                 is_public: true,
                 group_id: group.id,
                 multi_activity_id: @multi_activity.id
               }
             }
      end
      coordinator = MultiCoordinator.last
      assert coordinator.is_public
      assert_equal group.id, coordinator.group_id
    end

    test 'POST #create public coordinator without a group (ministère) fails' do
      sign_in @employer

      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=16%20BOULEVARD%20DES%20ITALIENS%2075009%20PARIS')
        .to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      assert_no_difference('MultiCoordinator.count') do
        post dashboard_multi_stepper_multi_coordinators_path,
             params: {
               multi_coordinator: {
                 siret: '66204244900014',
                 employer_chosen_name: 'BNP PARIBAS',
                 employer_chosen_address: '16 BOULEVARD DES ITALIENS 75009 PARIS',
                 city: 'PARIS',
                 zipcode: '75009',
                 street: '16 BOULEVARD DES ITALIENS',
                 phone: '0653615361',
                 sector_id: @sector.id,
                 is_public: true,
                 group_id: nil,
                 multi_activity_id: @multi_activity.id
               }
             }
      end
      assert_response :bad_request
    end

    test 'POST #create private coordinator with sector Fonction publique fails' do
      sign_in @employer
      fonction_publique = Sector.find_by(name: 'Fonction publique')

      stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=fr&addressdetails=1&format=json&q=16%20BOULEVARD%20DES%20ITALIENS%2075009%20PARIS')
        .to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      assert_no_difference('MultiCoordinator.count') do
        post dashboard_multi_stepper_multi_coordinators_path,
             params: {
               multi_coordinator: {
                 siret: '66204244900014',
                 employer_chosen_name: 'BNP PARIBAS',
                 employer_chosen_address: '16 BOULEVARD DES ITALIENS 75009 PARIS',
                 city: 'PARIS',
                 zipcode: '75009',
                 street: '16 BOULEVARD DES ITALIENS',
                 phone: '0653615361',
                 sector_id: fonction_publique.id,
                 is_public: false,
                 multi_activity_id: @multi_activity.id
               }
             }
      end
      assert_response :bad_request
    end

    test 'PATCH #update switching coordinator to public with a group succeeds' do
      sign_in @employer
      group = create(:group, is_public: true)

      patch dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator),
            params: {
              multi_coordinator: {
                is_public: true,
                group_id: group.id,
                sector_id: @sector.id
              }
            }
      multi_corporation = MultiCorporation.find_by(multi_coordinator: @multi_coordinator)
      assert_redirected_to edit_dashboard_multi_stepper_multi_corporation_path(multi_corporation)
      @multi_coordinator.reload
      assert @multi_coordinator.is_public
      assert_equal group.id, @multi_coordinator.group_id
    end

    test 'PATCH #update switching coordinator back to private clears the group' do
      sign_in @employer
      group = create(:group, is_public: true)
      @multi_coordinator.update!(is_public: true, group: group)

      patch dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator),
            params: {
              multi_coordinator: {
                is_public: false,
                group_id: group.id,
                sector_id: @sector.id
              }
            }
      multi_corporation = MultiCorporation.find_by(multi_coordinator: @multi_coordinator)
      assert_redirected_to edit_dashboard_multi_stepper_multi_corporation_path(multi_corporation)
      @multi_coordinator.reload
      refute @multi_coordinator.is_public
      assert_nil @multi_coordinator.group_id
    end
  end
end
