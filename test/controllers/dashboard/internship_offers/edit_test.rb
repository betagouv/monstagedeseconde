# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class EditTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #edit as visitor redirects to user_session_path' do
      get edit_dashboard_internship_offer_path(create(:weekly_internship_offer_2nde).to_param)
      assert_redirected_to user_session_path
    end

    test 'GET #edit as employer not owning internship_offer redirects to user_session_path' do
      sign_in(create(:employer))
      get edit_dashboard_internship_offer_path(create(:weekly_internship_offer_2nde).to_param)
      assert_redirected_to root_path
    end

    test 'GET #edit as employer owning internship_offer renders success' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer = create(:weekly_internship_offer_3eme, employer:,
                                                               max_candidates: 2)
      get edit_dashboard_internship_offer_path(internship_offer.to_param)
      assert_select "#internship_offer_max_candidates[value=#{internship_offer.max_candidates}]", count: 1
      assert_response :success
    end

    test 'GET #edit post offer render selectable week of past year' do
      travel_to(Date.new(Date.today.year - 1, 6, 1)) do
        employer = create(:employer)
        school_year_n_minus_one = SchoolYear::Floating.new_by_year(year: Date.today.year - 1)

        first_week = Week.find_by(year: school_year_n_minus_one.beginning_of_period.year,
                                  number: school_year_n_minus_one.beginning_of_period.cweek)

        sign_in(employer)
        internship_offer = create(
          :weekly_internship_offer_3eme,
          employer:,
          weeks: [first_week],
          max_candidates: 1
        )
        get edit_dashboard_internship_offer_path(internship_offer.to_param)
        assert_response :success
      end
    end

    test 'GET #edit is not turboable' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer:)
      get edit_dashboard_internship_offer_path(internship_offer.to_param)
      assert_select 'meta[name="turbo-visit-control"][content="reload"]'
    end

    test 'GET #edit with disabled fields if applications exist' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer:,
                                                               internship_offer_area: employer.current_area)
      internship_application = create(:weekly_internship_application,
                                      :submitted,
                                      internship_offer:)
      travel_to(weeks.select { |w| w.year == 2024 }.first.week_date - 1.week) do
        get edit_dashboard_internship_offer_path(internship_application.internship_offer.to_param)
        assert_response :success
        assert_select 'input#internship_offer_max_candidates'
      end
    end

    test 'GET #edit with default fields' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer = create(:weekly_internship_offer_2nde, is_public: true,
                                                               max_candidates: 1,
                                                               employer:)

      get edit_dashboard_internship_offer_path(internship_offer.to_param)
      assert_response :success
      assert_select 'title', "Offre de stage '#{internship_offer.title}' | 1élève1stage"

      assert_select '#internship_type_true[checked]', count: 1
      assert_select '#internship_type_false[checked]', count: 0

      assert_select 'a.btn-back[href=?]', dashboard_internship_offers_path
    end
  end
end
