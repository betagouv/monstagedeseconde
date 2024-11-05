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
      skip 'this test is relevant and shall be reactivated by november 2024'
      employer = create(:employer)
      sign_in(employer)

      assert_changes 'InternshipOccupation.count', 1 do
        post(
          dashboard_stepper_internship_occupations_path,
          params: {
            internship_occupation: {
              title: 'Activités de découverte',
              street: '12 rue des bois',
              street_complement: 'Batiment 1',
              zipcode: '75001',
              city: 'Paris',
              coordinates: { latitude: 1, longitude: 1 },
              description: 'Activités de découverte avec des enfants',
              internship_address_manual_enter: false
            }
          }
        )
      end

      created_internship_occupation = InternshipOccupation.last

      assert_equal '12 rue des bois - Batiment 1', created_internship_occupation.street
      assert_equal '75001', created_internship_occupation.zipcode
      assert_equal 'Paris', created_internship_occupation.city
      assert_equal 'Activités de découverte avec des enfants', created_internship_occupation.description
      assert_equal 'Activités de découverte', created_internship_occupation.title
      assert_equal employer.id, created_internship_occupation.employer_id
      refute created_internship_occupation.internship_address_manual_enter

      assert_redirected_to new_dashboard_stepper_entreprise_path(internship_occupation_id: created_internship_occupation.id)
      follow_redirect!
      assert_select 'span#alert-text',
                    text: "L'adresse du stage et son intitulé ont bien été enregistrés"
      assert_select('h2 > span.fr-stepper__state', 'Étape 2 sur 3')
    end

    # test 'POST create with same Siret number redirects to new internship offer info' do
    # employer = create(:employer)
    # internship_occupation = create(:internship_occupation, siret: '12345678900000')
    # group  = create(:group, is_public: true)
    # sign_in(employer)

    # assert_no_changes "InternshipOccupation.count" do
    #   post(
    #     dashboard_stepper_internship_occupations_path,
    #     params: {
    #       internship_occupation: {
    #         employer_name: 'BigCorp',
    #         street: '12 rue des bois',
    #         zipcode: '75001',
    #         city: 'Paris',
    #         coordinates: { latitude: 1, longitude: 1 },
    #         employer_description_rich_text: '<div><b>Activités de découverte</b></div>',
    #         is_public: group.is_public,
    #         group_id: group.id,
    #         employer_website: 'www.website.com',
    #         siret: internship_occupation.siret
    #       }
    #     })
    # end
    # end

    # test 'when statistician POST create redirects to new internship offer info' do
    #   statistician = create(:statistician)
    #   group = create(:group, is_public: true)
    #   sign_in(statistician)

    #   assert_changes 'InternshipOccupation.count', 1 do
    #     post(
    #       dashboard_stepper_internship_occupations_path,
    #       params: {
    #         internship_occupation: {
    #           employer_name: 'BigCorp',
    #           street: '12 rue des bois',
    #           zipcode: '75001',
    #           city: 'Paris',
    #           coordinates: { latitude: 1, longitude: 1 },
    #           employer_description: 'Activités de découverte',
    #           is_public: group.is_public,
    #           group_id: group.id,
    #           employer_website: 'www.website.com'
    #         }
    #       }
    #     )
    #   end

    #   created_internship_occupation = InternshipOccupation.last
    #   assert_equal 'BigCorp', created_internship_occupation.employer_name
    #   assert_equal '12 rue des bois', created_internship_occupation.street
    #   assert_equal '75001', created_internship_occupation.zipcode
    #   assert_equal 'Paris', created_internship_occupation.city
    #   assert_equal 'Activités de découverte', created_internship_occupation.employer_description
    #   assert_equal 'www.website.com', created_internship_occupation.employer_website
    #   assert_equal statistician.id, created_internship_occupation.employer_id
    #   assert_equal true, created_internship_occupation.is_public
    #   assert_equal false, created_internship_occupation.manual_enter
    #   assert_equal group.id, created_internship_occupation.group_id

    #   assert_redirected_to new_dashboard_stepper_internship_offer_info_path(internship_occupation_id: created_internship_occupation.id)
    # end

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
            description_tich_text: 'Activités de découverte'
          }
          # missing title
        }
      )
      assert_response :bad_request
    end
  end
end
