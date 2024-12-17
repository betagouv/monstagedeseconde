# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferIndexTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end

  def assert_absence_of(internship_offer:)
    assert_no_selector "a[data-test-id='#{internship_offer.id}']"
  end

  test 'navigation & interaction works' do
    school = create(:school)
    student = create(:student, school:)
    internship_offer = create(:weekly_internship_offer_2nde)
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        visit internship_offers_path

        # assert_presence_of(internship_offer: internship_offer)
      end
    end
  end

  test 'pagination of internship_offers index is ok with api or weekly offers' do
    skip 'failing test on CI but passing locally' if ENV.fetch('CI') == 'true'
    travel_to Date.new(2025, 3, 1) do
      2.times do
        create(:weekly_internship_offer_2nde, city: 'Chatillon', coordinates: Coordinates.chatillon)
      end
      (InternshipOffer::PAGE_SIZE / 2).times do
        create(:weekly_internship_offer_2nde, city: 'Paris', coordinates: Coordinates.paris, zipcode: '75000')
        create(:api_internship_offer, city: 'Paris', coordinates: Coordinates.paris, zipcode: '75000')
      end
      student = create(:student)
      assert_equal 'Paris', student.school.city
      sign_in(student)
      visit internship_offers_path
      find('li a.fr-link', text: 'Recherche').click
      sleep 1
      selector = '.fr-text.fr-py-1w.test-city.fr-text--sm.fr-text--grey-425'
      within('.fr-test-internship-offers-container') do
        assert_selector(selector, text: 'Paris', count: InternshipOffer::PAGE_SIZE, wait: 5)
      end
      click_link 'Page suivante'
      within('.fr-test-internship-offers-container') do
        assert_selector(selector, text: 'Chatillon', count: 2, wait: 2)
      end
    end
  end

  test 'recommandation is shown when no offer is available' do
    travel_to Date.new(2024, 9, 1) do
      2.times do
        create(:weekly_internship_offer_2nde, city: 'Montmorency', coordinates: Coordinates.montmorency)
      end
      student = create(:student)
      assert_equal 'Paris', student.school.city
      sign_in(student)
      visit internship_offers_path(latitude: 48.8589, longitude: 2.347, city: 'paris', radius: 5_000)
      # there are no offers in Paris
      assert_selector('.test-city', text: 'Montmorency',
                                    count: 2, wait: 2)
    end
  end
end
