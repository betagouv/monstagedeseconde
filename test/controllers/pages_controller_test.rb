# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'home' do
    get root_path
    assert_response :success
    assert_template 'pages/home'
    assert_select 'title', 'Accueil | 1Élève1Stage'
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
    Flipper.enable(:maintenance_mode)
    get root_path
    assert_redirected_to '/maintenance.html'
  end

  test 'GET pages#mentions_legales works' do
    get mentions_legales_path
    assert_response :success
    assert_template 'pages/mentions_legales'
    assert_select 'title', 'Mentions légales | 1Élève1Stage'
  end

  test 'GET pages#conditions_d_utilisation works' do
    get conditions_d_utilisation_path
    assert_response :success
    assert_template 'pages/conditions_d_utilisation'
    assert_select 'title', "Conditions d'utilisation | 1Élève1Stage"
  end

  test 'GET pages#contact works' do
    get contact_path
    assert_response :success
    assert_template 'pages/contact'
    assert_select 'title', 'Contact | 1Élève1Stage'
  end

  test 'GET pages#accessibilite works' do
    get accessibilite_path
    assert_response :success
    assert_template 'pages/accessibilite'
    assert_select 'title', 'Accessibilité | 1Élève1Stage'
  end
end
