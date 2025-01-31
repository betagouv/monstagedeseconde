# frozen_string_literal: true

require 'test_helper'

class IndexTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_select "[data-test-id=#{internship_offer.id}]", 1
  end

  def assert_absence_of(internship_offer:)
    assert_select "[data-test-id=#{internship_offer.id}]", 0
  end

  def assert_json_presence_of(json_response, internship_offer)
    assert(json_response['internshipOffers'].any? { |o| o['id'] == internship_offer.id })
  end

  def assert_json_absence_of(json_response, internship_offer)
    assert(json_response['internshipOffers'].none? { |o| o['id'] == internship_offer.id })
  end

  def create_offers
    offer_paris_1 = create(
      :weekly_internship_offer_3eme,
      title: 'Vendeur'
    )
    offer_paris_2 = create(
      :weekly_internship_offer_3eme,
      title: 'Comptable'
    )
    offer_paris_3 = create(
      :weekly_internship_offer_3eme,
      title: 'Infirmier'
    )
    offer_bordeaux_1 = create(
      :weekly_internship_offer_3eme,
      title: 'Infirmier',
      city: 'Bordeaux',
      coordinates: Coordinates.bordeaux
    )
  end

  test 'GET #index as "Users::Visitor" works and has a page title' do
    get internship_offers_path
    assert_response :success
    assert_select 'title', 'Recherche de stages | 1Elève1Stage'
  end

  test 'GET #index with coordinates as "Users::Visitor" works' do
    get internship_offers_path(latitude: 44.8378, longitude: -0.579512)
    assert_response :success
  end

  test 'GET #index with wrong keyword as Visitor returns 5 last offers' do
    # create_offers
    5.times { create(:weekly_internship_offer_3eme) }
    get internship_offers_path(keyword: 'avcocat', format: :json)
    assert_response :success
    5.times { |i| assert_json_presence_of(json_response, InternshipOffer.all[i]) }
    assert_equal 0, UsersSearchHistory.count
  end

  test 'GET #index with no params as Student returns all offers' do
    create_offers
    sign_in(create(:student))
    get internship_offers_path(format: :json)
    assert_response :success
    refute_empty json_response['internshipOffers']
    assert_equal 1, UsersSearchHistory.count
    assert_equal 4, UsersSearchHistory.last.results_count
  end

  test 'GET #index with wrong coordinates as Visitor returns nothing' do
    create_offers
    get internship_offers_path(latitude: 4.8378, longitude: -0.579512, format: :json)
    assert_response :success
    assert_empty json_response['internshipOffers']
  end

  test 'GET #index withParis location as Visitor returns 3 offers' do
    offer_paris_1 = create(
      :weekly_internship_offer_3eme,
      title: 'Vendeur'
    )
    offer_paris_2 = create(
      :weekly_internship_offer_3eme,
      title: 'Comptable'
    )
    offer_paris_3 = create(
      :weekly_internship_offer_3eme,
      title: 'Infirmier'
    )
    # not displayed
    offer_bordeaux_1 = create(
      :weekly_internship_offer_3eme,
      title: 'Infirmier',
      city: 'Bordeaux',
      coordinates: Coordinates.bordeaux
    )
    # not displayed
    offer_bordeaux_2 = create(
      :weekly_internship_offer_3eme,
      title: 'Infirmier',
      city: 'Bordeaux',
      coordinates: Coordinates.bordeaux
    )

    get internship_offers_path(
      latitude: Coordinates.paris[:latitude],
      longitude: Coordinates.paris[:longitude],
      radius: 60_000,
      format: :json
    )

    assert_response :success
    assert_json_presence_of(json_response, offer_paris_1)
    assert_json_presence_of(json_response, offer_paris_2)
    assert_json_presence_of(json_response, offer_paris_3)
  end

  test 'GET #index canonical links works' do
    get internship_offers_path(latitude: 44.8378, longitude: -0.579512)
    assert_match(
      %r{<link href="http://www.example.com/offres-de-stage" rel="canonical" />}, response.body
    )
    get internship_offers_path(latitude: 44.8378, longitude: -0.579512, page: 2)
    assert_match(
      %r{<link href="http://www.example.com/offres-de-stage\?page=2" rel="canonical" />}, response.body
    )
  end

  test 'GET #index as student ignores internship_offers with existing application' do
    travel_to(Date.new(2024, 3, 1)) do
      internship_offer_without_application = create(
        :weekly_internship_offer_2nde,
        title: 'offer without_application'
      )

      assert_equal 1, InternshipOffers::WeeklyFramed.count

      school = create(:school)
      class_room = create(:class_room, school:)
      student = create(:student, :seconde, school:, class_room:)
      internship_offer_with_application = create(
        :weekly_internship_offer_2nde,
        max_candidates: 2,
        max_students_per_group: 2,
        title: 'offer with_application'
      )

      internship_application = create(
        :internship_application,
        internship_offer: internship_offer_with_application,
        aasm_state: 'approved',
        student:
      )

      assert_equal 2, InternshipOffers::WeeklyFramed.count
      assert_equal 1, InternshipApplication.count
      assert_equal 1, InternshipApplication.approved.count
      assert_equal 1, internship_offer_with_application.reload.remaining_seats_count

      sign_in(student)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          assert_equal 2, InternshipOffers::WeeklyFramed.uncompleted_with_max_candidates.count
          get internship_offers_path, params: { format: :json }
          assert_response :success
          assert_equal 1, json_response['internshipOffers'].count
          assert_json_presence_of(json_response, internship_offer_without_application)
        end
      end
    end
  end

  test 'GET #index as statistician works' do
    statistician = create(:statistician)
    sign_in(statistician)
    get internship_offers_path
    assert_response :success
  end

  test 'GET #index as student. ignores internship offers not published' do
    travel_to(Date.new(2024, 3, 1)) do
      api_internship_offer         = create(:api_internship_offer_3eme)
      internship_offer_published   = create(:weekly_internship_offer_3eme)
      internship_offer_unpublished = create(:weekly_internship_offer_3eme, :unpublished)
      student = create(:student, :troisieme)
      sign_in(student)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          get internship_offers_path, params: { format: :json }
          assert_equal 2, json_response['internshipOffers'].count
          assert_json_absence_of(json_response, internship_offer_unpublished)
          assert_json_presence_of(json_response, api_internship_offer)
          assert_json_presence_of(json_response, internship_offer_published)
        end
      end
    end
  end

  test 'GET #index as visitor does not show discarded offers' do
    travel_to(Date.new(2024, 3, 1)) do
      discarded_internship_offer = create(:weekly_internship_offer_2nde,
                                          discarded_at: 2.days.ago)
      not_discarded_internship_offer = create(:weekly_internship_offer_2nde,
                                              discarded_at: nil)
      get internship_offers_path, params: { format: :json }
      assert_json_presence_of(json_response, not_discarded_internship_offer)
      assert_json_absence_of(json_response, discarded_internship_offer)
    end
  end

  test 'GET #index as visitor does not show unpublished offers' do
    travel_to(Date.new(2024, 3, 1)) do
      published_internship_offer = create(:weekly_internship_offer_2nde,
                                          aasm_state: 'published',
                                          published_at: 2.days.ago)
      not_published_internship_offer = create(:weekly_internship_offer_2nde, :unpublished)
      get internship_offers_path, params: { format: :json }
      assert_json_presence_of(json_response, published_internship_offer)
      assert_json_absence_of(json_response, not_published_internship_offer)
    end
  end

  test 'GET #index as visitor does not show fulfilled offers' do
    travel_to(Date.new(2024, 9, 1)) do
      internship_application = create(:weekly_internship_application, :submitted)
      internship_offer = internship_application.internship_offer
      get internship_offers_path, params: { format: :json }
      assert_json_presence_of(json_response, internship_offer)
      internship_application.update!(aasm_state: 'approved')
      get internship_offers_path, params: { format: :json }
      assert_json_absence_of(json_response, internship_offer)
    end
  end

  test 'GET #index as visitor or student default shows both middle school and high school offers' do
    internship_offer_weekly = create(:weekly_internship_offer_3eme)
    # Visitor
    get internship_offers_path
    # Student
    school = create(:school)
    student = create(:student, school:)
    sign_in(student)
    get internship_offers_path
  end

  test 'GET #index as student ignores internship_offers having ' \
       'as much internship_application as max_candidates number' do
    max_candidates = 1
    week = Week.first
    school = create(:school)
    student = create(:student, school:,
                               class_room: create(:class_room,
                                                  school:))
    internship_offer = create(:weekly_internship_offer_3eme,
                              max_candidates:)
    internship_application = create(:internship_application,
                                    internship_offer:, aasm_state: 'approved')

    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      get internship_offers_path, params: { format: :json }
      assert_json_absence_of(json_response, internship_offer)
    end
  end

  test 'GET #index as student keeps internship_offers having ' \
       'as less than blocked_applications_count as max_candidates number' do
    max_candidates = 2
    internship_offer = create(:weekly_internship_offer_3eme,
                              max_candidates:)
    sign_in(create(:student))
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path, params: { format: :json }
        assert_json_presence_of(json_response, internship_offer)
      end
    end
  end

  test 'GET #index as student with page, returns paginated content' do
    # Api offers are ordered by creation date, so we can't test pagination with cities
    travel_to(Date.new(2024, 3, 1)) do
      # Student school is in Paris
      sign_in(create(:student, :seconde))
      internship_offers = InternshipOffer::PAGE_SIZE.times.map do
        create(:api_internship_offer_2nde, coordinates: Coordinates.bordeaux, city: 'Bordeaux')
      end
      # this one is in Paris, but it's the last one
      create(:api_internship_offer_2nde)
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        InternshipOffer.stub :in_the_future, InternshipOffer.all do
          get internship_offers_path, params: { format: :json }
          json_response.first[1].each do |internship_offer|
            assert_equal 'Bordeaux', internship_offer['city']
          end
          assert_equal InternshipOffer::PAGE_SIZE, json_response.first[1].count

          get internship_offers_path(page: 2, format: :json)
          assert_equal 1, json_response.first[1].count
          assert_equal 'Paris', json_response.first[1][0]['city']
        end
      end
    end
  end

  test 'GET #index as student with InternshipOffers::Api, returns paginated content' do
    travel_to(Date.new(2025, 3, 1)) do
      internship_offers = InternshipOffer::PAGE_SIZE.times.map do
        create(:api_internship_offer_3eme)
      end
      create(:api_internship_offer_3eme, coordinates: Coordinates.bordeaux, city: 'Bordeaux')
      sign_in(create(:student))
      
      InternshipOffer.stub :in_the_future, InternshipOffer.all do
        get internship_offers_path, params: { format: :json }
        json_response.first[1].each do |internship_offer|
          assert_equal 'Paris', internship_offer['city']
        end
        assert_equal InternshipOffer::PAGE_SIZE, json_response.first[1].count

        get internship_offers_path(page: 2, format: :json)

        assert_equal 1, json_response.first[1].count
        assert_equal 'Bordeaux', json_response.first[1][0]['city']
      end
    end
  end

  test 'search by location (radius) works' do
    travel_to(Date.new(2024, 3, 1)) do
      internship_offer_at_paris = create(:api_internship_offer_3eme,
                                         coordinates: Coordinates.paris)
      internship_offer_at_verneuil = create(:api_internship_offer_3eme,
                                            coordinates: Coordinates.verneuil)

      get internship_offers_path(latitude: Coordinates.paris[:latitude],
                                 longitude: Coordinates.paris[:longitude],
                                 radius: 60_000,
                                 format: :json)
      assert_json_presence_of(json_response, internship_offer_at_verneuil)
      assert_json_presence_of(json_response, internship_offer_at_paris)

      get internship_offers_path(latitude: Coordinates.verneuil[:latitude],
                                 longitude: Coordinates.verneuil[:longitude],
                                 radius: 5_000,
                                 format: :json)
      assert_json_presence_of(json_response, internship_offer_at_verneuil)
      assert_json_absence_of(json_response, internship_offer_at_paris)
    end
  end

  test 'GET #index?latitude=?&longitude=? as student returns internship_offer 60km around this location' do
    travel_to(Date.new(2024, 3, 1)) do
      week = Week.find_by(year: 2019, number: 10)
      school_at_paris = create(:school, :at_paris)
      student = create(:student, :seconde, school: school_at_paris)
      internship_offer_at_paris = create(:weekly_internship_offer_2nde,
                                         coordinates: Coordinates.paris)
      internship_offer_at_bordeaux = create(:weekly_internship_offer_2nde,
                                            coordinates: Coordinates.bordeaux)

      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        sign_in(student)

        get internship_offers_path(latitude: Coordinates.bordeaux[:latitude],
                                   longitude: Coordinates.bordeaux[:longitude],
                                   format: :json)
        assert_response :success
        assert_json_absence_of(json_response, internship_offer_at_paris)
        assert_json_presence_of(json_response, internship_offer_at_bordeaux)
      end
    end
  end

  test 'GET #index as student ignores internship_offer farther than 60 km nearby school coordinates' do
    week = Week.find_by(year: 2019, number: 10)
    school_at_bordeaux = create(:school, :at_bordeaux)
    student = create(:student, :troisieme, school: school_at_bordeaux)
    create(:weekly_internship_offer_3eme, coordinates: Coordinates.paris)

    InternshipOffer.stub :by_weeks, InternshipOffer.all do
      sign_in(student)
      travel_to(Date.new(2024, 3, 1)) do
        get internship_offers_path, params: { format: :json }

        assert_response :success
        assert_select '.offer-row', 0
      end
    end
  end

  test 'GET #index as student not filtering by weeks shows all offers' do
    travel_to(Date.new(2024, 3, 1)) do
      week = Week.find_by(year: 2019, number: 10)
      school = create(:school)
      student = create(:student, school:,
                                 class_room: create(:class_room, school:))
      offer_overlaping_school_weeks = create(:weekly_internship_offer_3eme)
      offer_not_overlaping_school_weeks = create(:weekly_internship_offer_3eme)
      sign_in(student)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        get internship_offers_path, params: { format: :json }
        assert_json_presence_of(json_response, offer_overlaping_school_weeks)
        assert_json_presence_of(json_response, offer_not_overlaping_school_weeks)
      end
    end
  end

  #
  # Employer
  #
  test 'GET #index as employer returns all internship offers' do
    employer = create(:employer)
    included_internship_offer = create(:weekly_internship_offer_3eme,
                                       employer:, title: 'Hellow-me')
    excluded_internship_offer = create(:weekly_internship_offer_3eme,
                                       title: 'Not hellow-me')
    sign_in(employer)
    get internship_offers_path, params: { format: :json }
    assert_response :success
    assert_json_presence_of(json_response, included_internship_offer)
    assert_json_presence_of(json_response, excluded_internship_offer)
  end

  test 'GET #index as god returns all internship_offers' do
    sign_in(create(:god))
    internship_offer_1 = create(:weekly_internship_offer_3eme, title: 'Hellow-me')
    internship_offer_2 = create(:weekly_internship_offer_3eme,
                                title: 'Not hellow-me')
    get internship_offers_path, params: { format: :json }
    assert_response :success
    assert_json_presence_of(json_response, internship_offer_1)
    assert_json_presence_of(json_response, internship_offer_2)
  end

  test 'GET #index as god. does not return discarded offers' do
    discarded_internship_offer = create(:weekly_internship_offer_3eme)
    discarded_internship_offer.discard
    god = create(:god)

    sign_in(god)
    get internship_offers_path, params: { format: :json }

    assert_response :success
    assert_select 'a[href=?]',
                  internship_offer_url(discarded_internship_offer), 0
  end

  test 'search with school years works' do
    employer = create(:employer)
    sign_in(employer)
    offer_1 = nil
    offer_2 = nil
    offer_3 = nil
    travel_to(Date.new(2024, 3, 1)) do
      offer_1 = create(:weekly_internship_offer_2nde, :week_1, school_year: 2024, employer:)
      assert_equal Date.new(2024, 6, 21), offer_1.last_date
    end
    travel_to(Date.new(2025, 3, 1)) do
      offer_2 = create(:weekly_internship_offer_2nde, :week_2, school_year: 2025, employer:)
    end
    travel_to(Date.new(2026, 3, 1)) do
      offer_3 = create(:weekly_internship_offer_2nde, :both_weeks, school_year: 2026, employer:)
    end
    assert_equal Date.new(2024, 6, 21), offer_1.last_date
    assert_equal Date.new(2025, 6, 27), offer_2.last_date
    assert_equal Date.new(2026, 6, 26), offer_3.last_date
    travel_to(Date.new(2024, 3, 1)) do
      sign_in(employer)
      get internship_offers_path(school_year: 2024, format: :json)
      assert_response :success
      assert_json_presence_of(json_response, offer_1)
      assert_json_absence_of(json_response, offer_2)
      assert_json_absence_of(json_response, offer_3)
      sign_out(employer)
    end
    travel_to(Date.new(2025, 3, 1)) do
      sign_in(employer)
      get internship_offers_path(school_year: 2025, format: :json)
      assert_response :success
      assert_json_absence_of(json_response, offer_1)
      assert_json_presence_of(json_response, offer_2)
      assert_json_absence_of(json_response, offer_3)
      sign_out(employer)
    end
    travel_to(Date.new(2026, 3, 1)) do
      sign_in(employer)
      get internship_offers_path(school_year: 2026, format: :json)
      assert_response :success
      assert_json_absence_of(json_response, offer_1)
      assert_json_absence_of(json_response, offer_2)
      assert_json_presence_of(json_response, offer_3)
      sign_out(employer)
    end
  end

  test 'method determine_school_weeks' do
    school = create(:school)
    student = create(:student, :troisieme, school: school)
    foundable_internship_offer = create(:weekly_internship_offer_3eme)
    refute student.school.off_constraint_school_weeks(student.grade).empty?
    travel_to(Date.new(2025, 3, 1)) do
      sign_in(student)
      get internship_offers_path(school_year: 2025, format: :json)
      assert_response :success
      assert_json_presence_of(json_response, foundable_internship_offer)
    end
  end
  test 'method determine_school_weeks for visitor' do
    foundable_internship_offer = create(:weekly_internship_offer_3eme)
    travel_to(Date.new(2025, 3, 1)) do
      get internship_offers_path(school_year: 2025, format: :json)
      assert_response :success
      assert_json_presence_of(json_response, foundable_internship_offer)
    end
  end
end
