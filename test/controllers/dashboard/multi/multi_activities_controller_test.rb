# frozen_string_literal: true

require 'test_helper'

module Dashboard::Multi
  class MultiActivitiesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New MultiActivity
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_multi_multi_activity_path
      assert_redirected_to user_session_path
    end

    test 'GET new when logged in renders form' do
      employer = create(:employer)
      sign_in(employer)

      get new_dashboard_multi_multi_activity_path
      assert_response :success
      assert_select 'h1.h2', text: "Déposer une offre de stage pour plusieurs structures"
      assert_select 'form'
      assert_select 'input[name="multi_activity[title]"]'
      assert_select 'textarea[name="multi_activity[description]"]'
    end

    #
    # Create MultiActivity
    #
    test 'POST create redirects to next step' do
      employer = create(:employer)
      sign_in(employer)

      assert_changes 'MultiActivity.count', 1 do
        post(
          dashboard_multi_multi_activities_path,
          params: {
            multi_activity: {
              title: 'Observation de différents métiers',
              description: 'Nous proposons un stage d\'une semaine pour les élèves de 3ème, qui se déroulera du lundi au vendredi. Voici le planning prévu : Lundi : Découverte de Bouygues, où les stagiaires apprendront les bases de la construction et des projets d\'infrastructure. Mardi : Visite chez Darty, avec une immersion dans le service client et la vente de produits électroniques.'
            }
          }
        )
      end

      created_multi_activity = MultiActivity.last

      assert_equal 'Observation de différents métiers', created_multi_activity.title
      assert_equal employer.id, created_multi_activity.employer_id
      assert created_multi_activity.description.present?

      assert_redirected_to new_dashboard_multi_multi_activity_path(
        id: created_multi_activity.id, submit_button: true
      )
      follow_redirect!
      assert_select 'span#alert-text', text: 'Les informations ont bien été enregistrées'
      assert_select('h2 > span.fr-stepper__state', 'Étape 1 sur 4')
    end

    test 'POST create render new when missing title' do
      sign_in(create(:employer))

      post(
        dashboard_multi_multi_activities_path,
        params: {
          multi_activity: {
            description: 'Description du stage'
            # missing title
          }
        }
      )
      assert_response :bad_request
      assert_select 'form'
    end

    test 'POST create render new when missing description' do
      sign_in(create(:employer))

      post(
        dashboard_multi_multi_activities_path,
        params: {
          multi_activity: {
            title: 'Titre du stage'
            # missing description
          }
        }
      )
      assert_response :bad_request
      assert_select 'form'
    end

    test 'POST create render new when title too long' do
      sign_in(create(:employer))

      post(
        dashboard_multi_multi_activities_path,
        params: {
          multi_activity: {
            title: 'a' * 121, # exceeds 120 characters
            description: 'Description du stage'
          }
        }
      )
      assert_response :bad_request
      assert_select 'form'
    end

    test 'POST create render new when description too long' do
      sign_in(create(:employer))

      post(
        dashboard_multi_multi_activities_path,
        params: {
          multi_activity: {
            title: 'Titre du stage',
            description: 'a' * 1501 # exceeds 1500 characters
          }
        }
      )
      assert_response :bad_request
      assert_select 'form'
    end

    #
    # Edit MultiActivity
    #
    test 'GET edit renders form with existing data' do
      employer = create(:employer)
      multi_activity = create(:multi_activity, employer: employer)
      sign_in(employer)

      get edit_dashboard_multi_multi_activity_path(multi_activity)
      assert_response :success
      assert_select 'form'
      assert_select 'input[name="multi_activity[title]"][value=?]', multi_activity.title
      assert_select 'textarea[name="multi_activity[description]"]', text: multi_activity.description
    end

    #
    # Update MultiActivity
    #
    test 'PATCH update redirects to next step' do
      employer = create(:employer)
      multi_activity = create(:multi_activity, employer: employer)
      sign_in(employer)

      patch(
        dashboard_multi_multi_activity_path(multi_activity),
        params: {
          multi_activity: {
            title: 'Nouveau titre',
            description: 'Nouvelle description'
          }
        }
      )

      multi_activity.reload
      assert_equal 'Nouveau titre', multi_activity.title
      assert_equal 'Nouvelle description', multi_activity.description

      assert_redirected_to new_dashboard_multi_multi_activity_path(id: multi_activity.id)
    end

    test 'PATCH update render new when invalid' do
      employer = create(:employer)
      multi_activity = create(:multi_activity, employer: employer)
      sign_in(employer)

      patch(
        dashboard_multi_multi_activity_path(multi_activity),
        params: {
          multi_activity: {
            title: '', # invalid
            description: 'Description'
          }
        }
      )

      assert_response :bad_request
      assert_select 'form'
    end
  end
end

