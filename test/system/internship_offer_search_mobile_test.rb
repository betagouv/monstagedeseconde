# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferSearchMobileTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers
  include ::SearchInternshipOfferHelpers

  def submit_form
    find('#test-mobile-submit-search').click
  end

  def edit_search
    find('a[data-test-id="mobile-search-button"]').click
    find('.test-search-container')
  end

  test 'USE_IPHONE_EMULATION, search form is hidden, only shows cta to navigate to extracted form in a simple view' do
    visit internship_offers_path

    assert_selector('.search-container', visible: false)
    # assert_selector('a[data-test-id="mobile-search-button"]', visible: true)
    # find('a[data-test-id="mobile-search-button"]').click
    # find(".modal-fullscreen-lg")
  end

  test 'USE_IPHONE_EMULATION, search by location (city) works' do
    skip 'works locally, but not on CI' if ENV['CI'] == 'true'
    internship_offer_at_paris = create(:weekly_internship_offer_2nde,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:weekly_internship_offer_2nde,
                                          coordinates: Coordinates.bordeaux)

    visit eleves_path
    fill_in_city_or_zipcode(with: 'Pari', expect: 'Paris')
    submit_form

    # assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # reset search and submit
    # edit_search
    # fill_in_city_or_zipcode(with: '', expect: '')
    # submit_form
    # assert_presence_of(internship_offer: internship_offer_at_paris)
    # assert_presence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'USE_IPHONE_EMULATION, search by location (zipcodes) works' do
    skip 'works locally but not on CI' if ENV['CI'] == 'true'
    internship_offer_at_paris = create(:weekly_internship_offer_2nde,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:weekly_internship_offer_2nde,
                                          coordinates: Coordinates.bordeaux)

    visit eleves_path
    fill_in_city_or_zipcode(with: '75012', expect: 'Paris')

    submit_form
    # assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # reset search and submit
    # edit_search
    # fill_in_city_or_zipcode(with: '', expect: '')
    # submit_form
    # assert_presence_of(internship_offer: internship_offer_at_paris)
    # assert_presence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'USE_IPHONE_EMULATION, search by keyword works' do
    skip # TODO: reactive this test when search is functional
    searched_keyword = 'helloworld'
    searched_internship_offer = create(:weekly_internship_offer_2nde, title: searched_keyword)
    not_searched_internship_offer = create(:weekly_internship_offer_2nde)
    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now
    InternshipOfferKeyword.update_all(searchable: true)

    visit search_internship_offers_path
    fill_in_keyword(keyword: searched_keyword)
    submit_form
    # assert_presence_of(internship_offer: searched_internship_offer)
    assert_absence_of(internship_offer: not_searched_internship_offer)

    # reset search and submit
    # edit_search
    # fill_in_keyword(keyword: '')
    # submit_form
    # assert_presence_of(internship_offer: searched_internship_offer)
    # assert_presence_of(internship_offer: not_searched_internship_offer)
  end

  test 'USE_IPHONE_EMULATION, search by week works' do
    travel_to(Date.new(2020, 9, 6)) do
      skip 'TODO #mayflower'

      searched_internship_offer = create(:weekly_internship_offer_2nde)
      not_searched_internship_offer = create(:weekly_internship_offer_2nde)

      visit eleves_path

      fill_in_week(week: searched_week, open_popover: false)
      submit_form
      # assert_presence_of(internship_offer: searched_internship_offer)
      # assert_absence_of(internship_offer: not_searched_internship_offer)
      # TODO: ensure weeks navigation and months navigation
    end
  end

  test 'USE_IPHONE_EMULATION, search by all criteria' do
    skip # TODO: reactive this test when search is functional
    travel_to(Date.new(2025, 3, 1)) do
      searched_keyword = 'helloworld'
      searched_location = Coordinates.paris
      not_searched_keyword = 'bouhbouh'
      not_searched_location = Coordinates.bordeaux
      searched_opts = { title: searched_keyword,
                        coordinates: searched_location }
      # build findable
      findable_internship_offer = create(:weekly_internship_offer_2nde, searched_opts)

      # build ignored
      not_found_by_location = create(
        :weekly_internship_offer_2nde,
        searched_opts.merge(coordinates: Coordinates.bordeaux)
      )
      not_found_by_keyword = create(
        :weekly_internship_offer_2nde,
        searched_opts.merge(title: not_searched_keyword)
      )
      not_found_by_week = create(
        :weekly_internship_offer_2nde,
        searched_opts
      )

      dictionnary_api_call_stub
      SyncInternshipOfferKeywordsJob.perform_now
      InternshipOfferKeyword.update_all(searchable: true)

      visit search_internship_offers_path

      fill_in_city_or_zipcode(with: 'Pari', expect: 'Paris')
      fill_in_keyword(keyword: searched_keyword)

      submit_form

      # assert_presence_of(internship_offer: findable_internship_offer)
      assert_absence_of(internship_offer: not_found_by_location)
      assert_absence_of(internship_offer: not_found_by_keyword)
    end
  end
end
