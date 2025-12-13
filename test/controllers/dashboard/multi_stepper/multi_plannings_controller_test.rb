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
      assert_difference('MultiPlanning.count', 1) do
        post dashboard_multi_stepper_multi_plannings_path(multi_coordinator_id: @multi_coordinator.id), params: {
          multi_planning: {
            max_candidates: 3,
            lunch_break: '12h-14h',
            weekly_hours: ['9h-17h'],
            rep: false,
            qpv: true,
            all_year_long: '0',
            grade_college: '1',
            grade_2e: '0'
          }
        }
      end
      
      assert_redirected_to dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator)
      assert_equal 'Planning créé avec succès', flash[:notice]
    end

    test 'POST #create with invalid params renders new' do
      assert_no_difference('MultiPlanning.count') do
        post dashboard_multi_stepper_multi_plannings_path(multi_coordinator_id: @multi_coordinator.id), params: {
          multi_planning: {
            max_candidates: nil, # Invalid
            lunch_break: ''
          }
        }
      end
      
      assert_response :bad_request
    end

    test 'GET #edit returns success' do
      get edit_dashboard_multi_stepper_multi_planning_path(@multi_planning)
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
      patch dashboard_multi_stepper_multi_planning_path(@multi_planning), params: {
        multi_planning: {
          max_candidates: -1 # Invalid
        }
      }
      
      assert_response :bad_request
    end
  end
end
