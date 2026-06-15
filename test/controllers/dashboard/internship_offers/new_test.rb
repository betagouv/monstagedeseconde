# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class NewTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #new as Employer with duplicate_id' do
      # operator = create(:user_operator)
      # internship_offer = create(:weekly_internship_offer, employer: operator,
      #                                                     is_public: true,
      #                                                     max_candidates: 2,
      #                                                     max_students_per_group: 2)
      # sign_in(internship_offer.employer)
      # get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id)
      # assert_select 'h1', "Dupliquer une offre"
      # assert_select "input[value=\"#{internship_offer.title}\"]", count: 1
      # assert_select '#internship_offer_is_public_true[checked]',
      #               count: 1 # "ensure user select kind of group"
      # assert_select '#internship_offer_is_public_false[checked]',
      #               count: 0 # "ensure user select kind of group"
      # assert_select '.form-group-select-group.d-none', count: 0
      # assert_select '.form-group-select-group', count: 1

      # assert_select '#internship_type_true[checked]', count: 0
      # assert_select '#internship_type_false[checked]', count: 1
      # assert_select '.form-group-select-max-candidates.d-none', count: 0
      # assert_select '.form-group-select-max-candidates', count: 1
      # assert_select 'meta[name="turbo-visit-control"][content="reload"]'
      # sign_out(internship_offer.employer)

      # god = create(:god)
      # sign_in(god)
      # get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id)
      # assert_select 'h1', {
      #   count: 0,
      #   text: "Renouveler l'offre pour l'année en cours"
      # }
      # sign_out(god)

      # student = create(:student)
      # sign_in(student)
      # get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id)
      # assert_select 'h1', {
      #   count: 0,
      #   text: "Renouveler l'offre pour l'année en cours"
      # }
    end

    test 'GET #new as Employer with duplicate_id for a troisieme offer during troisieme no dates available period shows grade_college checkbox disabled and unchecked' do
      travel_to Date.new(2026, 6, 10) do
        employer = create(:employer)
        sign_in(employer)
        internship_offer = create(:weekly_internship_offer_3eme, employer:, max_candidates: 2,
                                                                  internship_offer_area: employer.current_area)
        get new_dashboard_internship_offer_path(duplicate_id: internship_offer.id)
        assert_response :success
        assert_select '#internship_offer_grade_college[disabled]'
        assert_select '#internship_offer_grade_college[checked]', count: 0
      end
    end
  end
end
