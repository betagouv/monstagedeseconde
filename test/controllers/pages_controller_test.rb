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

  test 'GET pages#regional_partners_index shows the partners carousel' do
    PagesController.stub_any_instance(:get_all_partners, fake_partners) do
      get partners_path
    end
    assert_response :success
    assert_template 'pages/regional_partners_index'
    assert_carousel_markup
  end

  test 'home shows the partners carousel' do
    PagesController.stub_any_instance(:get_all_partners, fake_partners) do
      get root_path
    end
    assert_response :success
    assert_carousel_markup
  end

  test 'GET pages#pro_landing shows the partners carousel' do
    PagesController.stub_any_instance(:get_all_partners, fake_partners) do
      get "/professionnels"
    end
    assert_response :success
    assert_template 'pages/pro_landing'
    assert_carousel_markup
  end

  test 'GET pages#regional_partners_index without partners hides the carousel' do
    get partners_path
    assert_response :success
    assert_select 'section.partners-carousel', count: 0
  end

  private

  def fake_partners
    (1..5).map do |i|
      { name: "Partenaire #{i}", logo: "https://images.prismic.io/logo-#{i}.png", url: "https://partenaire-#{i}.fr" }
    end
  end

  def assert_carousel_markup
    assert_select 'section.partners-carousel[aria-labelledby="partners-carousel-title"]' do
      assert_select 'h2#partners-carousel-title', 'Nos partenaires'
      assert_select 'button[data-carousel-target="playButton"]'
      # logos are rendered twice to build the seamless scrolling loop,
      # the duplicate set being hidden from assistive technologies
      assert_select 'img[alt="Partenaire 1"]', count: 2
      assert_select '[aria-hidden="true"] img[alt="Partenaire 1"]', count: 1
      assert_select 'a[href="https://partenaire-1.fr"]', count: 2
      assert_select '[aria-hidden="true"] a[href="https://partenaire-1.fr"][tabindex="-1"]', count: 1
    end
  end
end
