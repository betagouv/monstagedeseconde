require 'test_helper'

module Dashboard::MultiStepper
  class MultiPlanningsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @employer = create(:employer)
      @multi_activity = create(:multi_activity, employer: @employer)
      @multi_coordinator = create(:multi_coordinator, multi_activity: @multi_activity)
      @multi_corporation = create(:multi_corporation, multi_coordinator: @multi_coordinator)
      @multi_planning = create(:multi_planning, multi_coordinator: @multi_coordinator)
      
      sign_in(@employer)
    end

    test 'GET #new returns success' do
      get new_dashboard_multi_stepper_multi_planning_path(multi_coordinator_id: @multi_coordinator.id, multi_corporation_id: @multi_corporation.id)
      assert_response :success
    end

    test 'POST #create with valid params redirects to next step' do
      create(:corporation, multi_corporation: @multi_corporation)
      week = Week.selectable_from_now_until_end_of_school_year.first

      assert_difference(['MultiPlanning.count', 'InternshipOffer.count'], 1) do
        post dashboard_multi_stepper_multi_plannings_path(multi_coordinator_id: @multi_coordinator.id), params: {
          multi_planning: {
            max_candidates: 3,
            lunch_break: '12h-14h',
            weekly_hours: ['9h-17h'],
            rep: false,
            qpv: true,
            all_year_long: '0',
            grade_college: '1',
            grade_2e: '0',
            week_ids: [week.id]
          }
        }
      end
      
      created_offer = InternshipOffer.last
      assert_equal true, created_offer.from_multi?
      assert_equal @multi_coordinator.sector_id, created_offer.sector_id
      
      assert_redirected_to internship_offer_path(created_offer, origine: 'dashboard', stepper: true)
      assert_equal 'Les informations de planning ont bien été enregistrées. Votre offre est publiée', flash[:notice]
    end

    test 'POST #create with invalid params renders new' do
      assert_no_difference('MultiPlanning.count') do
        post dashboard_multi_stepper_multi_plannings_path(multi_coordinator_id: @multi_coordinator.id, multi_corporation_id: @multi_corporation.id), params: {
          multi_planning: {
            max_candidates: nil, # Invalid
            lunch_break: ''
          }
        }
      end
      
      assert_response :bad_request
    end

    test 'GET #edit returns success' do
      get edit_dashboard_multi_stepper_multi_planning_path(@multi_planning, multi_corporation_id: @multi_corporation.id)
      assert_response :success
    end

    test 'PATCH #update with valid params redirects' do
      patch dashboard_multi_stepper_multi_planning_path(@multi_planning), params: {
        multi_planning: {
          max_candidates: 10
        }
      }
      
      assert_redirected_to dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator)
      @multi_planning.reload
      assert_equal 10, @multi_planning.max_candidates
    end

    test 'PATCH #update with invalid params renders edit' do
      patch dashboard_multi_stepper_multi_planning_path(@multi_planning, multi_corporation_id: @multi_corporation.id), params: {
        multi_planning: {
          max_candidates: -1 # Invalid
        }
      }
      
      assert_response :bad_request
    end
  end
end
