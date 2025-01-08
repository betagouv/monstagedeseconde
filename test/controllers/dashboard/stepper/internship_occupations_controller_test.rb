# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class InternshipOccupationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New InternshipOccupation
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_stepper_internship_occupation_path
      assert_redirected_to user_session_path
    end

    #
    # Create InternshipOccupation
    #
    test 'POST create redirects to new entreprise' do
      employer = create(:employer)
      sign_in(employer)

      assert_changes 'InternshipOccupation.count', 1 do
        post(
          dashboard_stepper_internship_occupations_path,
          params: {
            internship_occupation: {
              title: 'Activités de découverte',
              street: '12 rue des bois',
              zipcode: '75001',
              city: 'Paris',
              coordinates: { latitude: 1, longitude: 1 },
              description: 'Activités de découverte avec des enfants'
            }
          }
        )
        # should be added when adding manual address entering
        # street_complement: 'Batiment 1',
      end

      created_internship_occupation = InternshipOccupation.last

      assert_equal '12 rue des bois', created_internship_occupation.street
      # assert_equal '12 rue des bois - Batiment 1', created_internship_occupation.street
      assert_equal '75001', created_internship_occupation.zipcode
      assert_equal 'Paris', created_internship_occupation.city
      assert_equal 'Activités de découverte avec des enfants', created_internship_occupation.description
      assert_equal 'Activités de découverte', created_internship_occupation.title
      assert_equal employer.id, created_internship_occupation.employer_id

      assert_redirected_to new_dashboard_stepper_entreprise_path(
        internship_occupation_id: created_internship_occupation.id, submit_button: true
      )
      follow_redirect!
      assert_select 'span#alert-text',
                    text: "L'adresse du stage et son intitulé ont bien été enregistrés"
      assert_select('h2 > span.fr-stepper__state', 'Étape 2 sur 3')
    end

    test 'POST create render new when missing params' do
      sign_in(create(:employer))

      post(
        dashboard_stepper_internship_occupations_path,
        params: {
          internship_occupation: {
            street: '12 rue des bois',
            zipcode: '75001',
            city: 'Paris',
            coordinates: { latitude: 1, longitude: 1 },
            description: 'Activités de découverte'
          }
          # missing title
        }
      )
      assert_response :bad_request
    end
  end
end
