require 'test_helper'

module Dashboard::MultiStepper
  class MultiCorporationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @employer = create(:employer)
      @multi_activity = create(:multi_activity, employer: @employer)
      @multi_coordinator = create(:multi_coordinator, multi_activity: @multi_activity)
      @multi_corporation = create(:multi_corporation, multi_coordinator: @multi_coordinator)
      
      sign_in(@employer)
    end

    test 'GET #new returns success' do
      get new_dashboard_multi_stepper_multi_corporation_path(multi_coordinator_id: @multi_coordinator.id)
      assert_response :success
    end

    test 'POST #create with valid params redirects to edit' do
      assert_difference('MultiCorporation.count', 1) do
        post dashboard_multi_stepper_multi_corporations_path, params: {
          multi_corporation: {
            multi_coordinator_id: @multi_coordinator.id
          }
        }
      end
      
      assert_redirected_to edit_dashboard_multi_stepper_multi_corporation_path(MultiCorporation.last)
    end

    test 'GET #edit returns success' do
      get edit_dashboard_multi_stepper_multi_corporation_path(@multi_corporation)
      assert_response :success
    end

    test 'PATCH #update redirects to new planning when no planning exists' do
      patch dashboard_multi_stepper_multi_corporation_path(@multi_corporation), params: {
        multi_corporation: {
          multi_coordinator_id: @multi_coordinator.id
        }
      }
      
      assert_redirected_to new_dashboard_multi_stepper_multi_planning_path(multi_coordinator_id: @multi_coordinator.id)
    end

    test 'PATCH #update redirects to edit planning when planning exists' do
      multi_planning = create(:multi_planning, multi_coordinator: @multi_coordinator)
      
      patch dashboard_multi_stepper_multi_corporation_path(@multi_corporation), params: {
        multi_corporation: {
          multi_coordinator_id: @multi_coordinator.id
        }
      }
      
      assert_redirected_to edit_dashboard_multi_stepper_multi_planning_path(multi_planning)
    end
  end
end

