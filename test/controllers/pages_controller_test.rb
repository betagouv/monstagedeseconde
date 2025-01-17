# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'home' do
    get root_path
    assert_response :success
    assert_template 'pages/home'
    assert_select 'title', 'Accueil | 1Elève1Stage'
  end

  test 'GET home after too many requests' do
    skip 'works locally but fails on CI' if ENV['CI'] == 'true'
    if ENV.fetch('TEST_WITH_MAX_REQUESTS_PER_MINUTE', false) == 'true'
      ApplicationController.const_set('MAX_REQUESTS_PER_MINUTE', 5)
      6.times do
        get root_path
      end
      ApplicationController.const_set('MAX_REQUESTS_PER_MINUTE', 10_000)
      assert_response :too_many_requests
    end
  end

  test 'GET home when maintenance mode is on' do
    ENV['MAINTENANCE_MODE'] = 'true'
    get root_path
    assert_redirected_to '/maintenance.html'
  end

  test '10_commandements_d_une_bonne_offre' do
    get les_10_commandements_d_une_bonne_offre_path
    assert_response :success
    assert_template 'pages/les_10_commandements_d_une_bonne_offre'
    assert_select 'title', 'Les 10 commandements pour une bonne offre | 1Elève1Stage'
  end

  test 'GET pages#mentions_legales works' do
    get mentions_legales_path
    assert_response :success
    assert_template 'pages/mentions_legales'
    assert_select 'title', 'Mentions légales | 1Elève1Stage'
  end

  test 'GET pages#conditions_d_utilisation works' do
    get conditions_d_utilisation_path
    assert_response :success
    assert_template 'pages/conditions_d_utilisation'
    assert_select 'title', "Conditions d'utilisation | 1Elève1Stage"
  end

  test 'GET pages#contact works' do
    get contact_path
    assert_response :success
    assert_template 'pages/contact'
    assert_select 'title', 'Contact | 1Elève1Stage'
  end

  test 'GET pages#accessibilite works' do
    get accessibilite_path
    assert_response :success
    assert_template 'pages/accessibilite'
    assert_select 'title', 'Accessibilité | 1Elève1Stage'
  end

  test '#register_to_webinar fails when not referent' do
    student = create(:student)
    sign_in student
    get register_to_webinar_path
    assert_redirected_to root_path
  end

  test '#register_to_webinar succeds when referent' do
    travel_to Time.zone.local(2024, 1, 1, 12, 0, 0) do
      webinar_url = ENV.fetch('WEBINAR_URL')
      ministry_statistician = create(:ministry_statistician)
      sign_in ministry_statistician
      get register_to_webinar_path
      assert_redirected_to webinar_url
      assert_equal ministry_statistician.subscribed_to_webinar_at.to_date, Time.zone.today
    end
  end
end
