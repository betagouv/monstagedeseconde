# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # School Manager
    #
    # test 'GET #show as SchoolManagement does not display application when internship_offer is not reserved to school' do
    #   school = create(:school, :with_school_manager)
    #   class_room = create(:class_room, school: school)
    #   student = create(:student, class_room: class_room, school: school)
    #   main_teacher = create(:main_teacher, class_room: class_room, school: school)

    #   sign_in(main_teacher)
    #   internship_offer = create(:weekly_internship_offer_2nde)
    #   get internship_offer_path(internship_offer)

    #   assert_response :success
    #   assert_select 'title', "Offre de stage '#{internship_offer.title}' | Monstage"
    #   assert_select 'form[id=?]', 'new_internship_application', count: 0
    #   assert_select 'strong.tutor_name', text: internship_offer.tutor_name
    #   assert_select 'ul li.tutor_phone', text: "Portable : #{internship_offer.tutor_phone}"
    #   assert_select "a.tutor_email[href=\"mailto:#{internship_offer.tutor_email}\"]",
    #                 text: internship_offer.tutor_email
    # end

    #
    # Student
    #
    test 'GET #show as Student does increments view_count' do
      internship_offer = create(:weekly_internship_offer_2nde)
      sign_in(create(:student))
      assert_changes -> { internship_offer.reload.view_count },
                     from: 0,
                     to: 1 do
        get internship_offer_path(internship_offer)
      end
    end

    test 'GET #show as Student does increments view_count history' do
      internship_offer = create(:weekly_internship_offer_2nde)
      sign_in(create(:student))
      assert_changes -> { UsersInternshipOffersHistory.count },
                     from: 0,
                     to: 1 do
        get internship_offer_path(internship_offer)
      end
    end

    test 'GET #show with applications from other students' do
      skip 'this test is relevant and shall be reactivated by november 2024'
      travel_to(Date.new(2024, 1, 1)) do
        offer = create(
          :weekly_internship_offer_3eme,
          city: 'Bordeaux',
          coordinates: Coordinates.bordeaux,
          title: 'Vendeur de cannelés',
          max_candidates: 3
        )
        employer = InternshipOffer.last.employer
        application = create(
          :weekly_internship_application,
          :approved,
          internship_offer: offer
        )
        get internship_offer_path(offer)
        assert_select('button', text: 'Postuler', count: 0)

        assert_select('.period-label-test', text: '2 semaines - du 17 au 28 juin 2024')
      end
    end

    test 'GET #show with applications from other students reduces the number ' \
         'of available weeks with weeklist splitted version' do
      skip 'this test is relevant and shall be reactivated by november 2024'
      travel_to(Date.new(2024, 1, 1)) do
        offer = create(
          :weekly_internship_offer_3eme,
          city: 'Bordeaux',
          coordinates: Coordinates.bordeaux,
          title: 'Vendeur de cannelés',
          max_candidates: 3,
          period: 1 # week_1
        )
        employer = InternshipOffer.last.employer
        application = create(
          :weekly_internship_application,
          :approved,
          internship_offer: offer
        )
        get internship_offer_path(offer)
        assert_select('.period-label-test', text: '1 semaine - du 17 au 21 juin 2024')
      end
    end

    test 'GET #show with period 2' do
      skip 'this test is relevant and shall be reactivated by november 2024'
      travel_to(Date.new(2024, 1, 1)) do
        offer = create(
          :weekly_internship_offer_3eme,
          city: 'Bordeaux',
          coordinates: Coordinates.bordeaux,
          title: 'Vendeur de cannelés',
          max_candidates: 3,
          period: 2 # week_
        )
        employer = InternshipOffer.last.employer

        get internship_offer_path(offer)
        assert_select('.period-label-test', text: '1 semaine - du 24 au 28 juin 2024')
      end
    end

    test 'GET #show as Student with API offer' do
      travel_to(Date.new(2023, 10, 1)) do
        weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
        internship_offer = create(:api_internship_offer_2nde)
        student = create(:student, school: create(:school))
        sign_in(student)
        get internship_offer_path(internship_offer)
        assert_response :success
        assert_select 'a[href=?]', internship_offer.permalink
        assert_template 'internship_applications/call_to_action/_api'
      end
    end

    test 'GET #show as Student redirects to his tailored list of internship_offers when offer is discarded' do
      internship_offer = create(:weekly_internship_offer_2nde)
      student = create(:student, school: create(:school))
      sign_in(student)

      internship_offer.discard

      get internship_offer_path(internship_offer)
      assert_redirected_to student.presenter.default_internship_offers_path
    end

    test 'GET #show as Student a message when he cannot apply to a reserved internship offer' do
      student = create(:student, school: create(:school))
      other_school = create(:school)
      internship_offer = create(:weekly_internship_offer_3eme, school: other_school, max_candidates: 5)
      sign_in(student)
      get internship_offer_path(internship_offer)

      assert_match "Offre réservée à l'établissement", response.body
      assert_match internship_offer.school.name, response.body
      assert_select '#new_internship_application', 0
    end

    test 'GET #show as Student shows next/previous navigation in list' do
      skip 'this test is relevant and shall be reactivated by november 2024'
      travel_to(Date.new(2024, 3, 1)) do
        previous_out = create(:weekly_internship_offer_2nde, title: 'previous_out')
        previous_in_page = create(:weekly_internship_offer_2nde, title: 'previous')
        current = create(:weekly_internship_offer_2nde, title: 'current')
        next_in_page = create(:weekly_internship_offer_2nde, title: 'next')
        next_out = create(:weekly_internship_offer_2nde, title: 'next_out')
        student = create(:student, school: create(:school))

        InternshipOffer.stub :nearby, InternshipOffer.all do
          sign_in(student)
          get internship_offer_path(current)

          assert_response :success
          assert_select 'a[href=?]', internship_offer_path(previous_in_page)
          assert_select 'a[href=?]', internship_offer_path(next_in_page)
        end
      end
    end

    test 'GET #show as Student shows next and not previous when no previous' do
      skip 'this test is relevant and shall be reactivated by november 2024'
      travel_to(Date.new(2024, 3, 1)) do
        current = create(:weekly_internship_offer_2nde, title: 'current')
        next_in_page = create(:weekly_internship_offer_2nde, title: 'next')
        next_out = create(:weekly_internship_offer_2nde, title: 'next_out')
        student = create(:student, school: create(:school))

        InternshipOffer.stub :nearby, InternshipOffer.all do
          InternshipOffer.stub :by_weeks, InternshipOffer.all do
            sign_in(student)
            get internship_offer_path(current)

            assert_response :success
            assert_select 'a.list-item-previous', count: 0
            assert_select 'a[href=?]', internship_offer_path(next_in_page)
          end
        end
      end
    end

    test 'GET #show as Student shows previous and not next when no not' do
      skip 'this test is relevant and shall be reactivated by november 2024'
      travel_to(Date.new(2024, 3, 1)) do
        previous_out = create(:weekly_internship_offer_2nde, title: 'previous_out')
        previous_in_page = create(:weekly_internship_offer_2nde, title: 'previous')
        current = create(:weekly_internship_offer_2nde, title: 'current')
        student = create(:student, school: create(:school))

        InternshipOffer.stub :nearby, InternshipOffer.all do
          InternshipOffer.stub :by_weeks, InternshipOffer.all do
            sign_in(student)
            get internship_offer_path(current)

            assert_response :success
            assert_select 'a[href=?]', internship_offer_path(previous_in_page)
            assert_select 'a.list-item-next', count: 0
          end
        end
      end
    end

    test 'GET #show as Student with forwards latitude, longitude & radius in params to next/prev ' do
      skip 'this test is relevant and shall be reactivated by november 2024'
      travel_to(Date.new(2024, 3, 1)) do
        previous_in_page = create(:weekly_internship_offer_2nde, title: 'previous')
        current = create(:weekly_internship_offer_2nde, title: 'current')
        next_in_page = create(:weekly_internship_offer_2nde, title: 'next')
        student = create(:student, school: create(:school))

        InternshipOffer.stub :nearby, InternshipOffer.all do
          InternshipOffer.stub :by_weeks, InternshipOffer.all do
            sign_in(student)
            get internship_offer_path(id: current, radius: 1_000, latitude: 1, longitude: 2)

            assert_response :success
            assert_select 'a[href=?]',
                          internship_offer_path(id: previous_in_page.id,
                                                latitude: 1,
                                                longitude: 2,
                                                radius: 1_000)
            assert_select 'a[href=?]',
                          internship_offer_path(id: next_in_page.id,
                                                latitude: 1,
                                                longitude: 2,
                                                radius: 1_000)
          end
        end
      end
    end

    #
    # Visitor
    #

    test 'GET #show as Visitor - canonical links works' do
      internship_offer = create(:weekly_internship_offer_2nde)
      regexp = Regexp.new("<link rel='canonical' href='http:\/\/www.example.com\/offres-de-stage\/(.*)' \/>")

      forwarded_params = { city: 'Mantes-la-Jolie' }
      get internship_offer_path({ id: internship_offer.id }.merge(forwarded_params))
      assert_match(regexp, response.body)
      id_arr = response.body.match(regexp).captures
      assert_equal id_arr.first.to_i, internship_offer.id

      forwarded_params.merge({ page: 2 })
      get internship_offer_path({ id: internship_offer.id }.merge(forwarded_params))
      assert_match(regexp, response.body)
      id_arr = response.body.match(regexp).captures
      assert_equal id_arr.first.to_i, internship_offer.id
    end

    test 'GET #show as Visitor when internship_offer is unpublished redirects to home' do
      internship_offer = create(:weekly_internship_offer_2nde)
      internship_offer.need_update!
      get internship_offer_path(internship_offer)
      assert_redirected_to internship_offers_path
    end

    test 'GET #show as Visitor shows sign up form' do
      internship_offer = create(:weekly_internship_offer_2nde)

      get internship_offer_path(internship_offer)
      assert_template 'internship_offers/_apply_cta'
    end

    test 'GET #show as Visitor does not increment view_count' do
      internship_offer = create(:weekly_internship_offer_2nde)

      assert_no_changes -> { internship_offer.reload.view_count } do
        get internship_offer_path(internship_offer)
      end
    end

    test 'GET #show website url when present' do
      internship_offer = create(:weekly_internship_offer_2nde, employer_website: 'http://google.com')
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select 'a.test-employer-website[href=?]', internship_offer.employer_website
    end

    #
    # Employer
    #
    test 'GET #show as Employer does not increment view_count' do
      internship_offer = create(:weekly_internship_offer_2nde)
      sign_in(internship_offer.employer)
      assert_no_changes -> { internship_offer.reload.view_count } do
        get internship_offer_path(internship_offer)
      end
    end

    test 'GET #show as Employer when internship_offer is unpublished works' do
      internship_offer = create(:weekly_internship_offer_2nde)
      internship_offer.need_update!
      sign_in(internship_offer.employer)
      get internship_offer_path(internship_offer)
      assert_response :success
      assert_select('button[disabled=disabled]', text: 'Postuler')
    end

    test 'GET #show as Student when internship_offer is unpublished shall redirect to' do
      internship_offer = create(:weekly_internship_offer_2nde)
      internship_offer.need_update!
      sign_in(create(:student))
      get internship_offer_path(internship_offer)
      assert_response :redirect
    end

    test 'GET #show as Employer displays internship_applications link' do
      published_at = 2.weeks.ago
      internship_offer = create(:weekly_internship_offer_2nde, published_at:)
      sign_in(internship_offer.employer)
      get internship_offer_path(internship_offer)
      assert_response :success
      assert_template 'dashboard/internship_offers/_navigation'

      assert_select 'a[href=?]', edit_dashboard_internship_offer_path(internship_offer),
                    { count: 1 },
                    'missing edit internship_offer link for employer'

      assert_select 'button[aria-controls="discard-internship-offer-modal"]',
                    { count: 2 },
                    'missing discard link for employer'

      assert_select 'span.internship_offer-published_at',
                    { text: "depuis le #{I18n.l(internship_offer.published_at, format: :human_mm_dd)}" },
                    'invalid published_at'

      assert_template 'dashboard/internship_offers/_delete_internship_offer_modal',
                      'missing discard modal for employer'
    end

    test "GET #show as employer have duplicate/renew button for last year's internship offer" do
      internship_offer = create(:weekly_internship_offer_2nde)

      sign_in(internship_offer.employer)

      get internship_offer_path(internship_offer)
      assert_response :success
      # assert_select '.test-duplicate-button', count: 1 # mobile and desktop
    end

    test 'GET #show as employer does show duplicate  button when internship_offer has been created durent current_year' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                created_at: SchoolYear::Current.new.beginning_of_period + 1.day)
      sign_in(internship_offer.employer)

      get internship_offer_path(internship_offer)
      assert_response :success
      # assert_select '.test-duplicate-button', count: 1
    end

    test 'sentry#1813654266, god can see api internship offer' do
      weekly_internship_offer = create(:weekly_internship_offer_2nde)
      api_internship_offer = create(:api_internship_offer_2nde)

      sign_in(create(:god))

      get internship_offer_path(weekly_internship_offer)
      assert_response :success

      get internship_offer_path(api_internship_offer)
      assert_response :success
    end
  end
end
