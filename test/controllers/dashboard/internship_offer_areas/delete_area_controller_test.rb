require 'test_helper'

module Dashboard
  module InternshipOfferAreas
    class DeleteAreaControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers
      include TeamAndAreasHelper

      test 'DELETE destroy_area when employer is alone' do
        employer = create(:employer)
        assert_equal 1, employer.internship_offer_areas.count
        # create a new area
        new_area = create(:internship_offer_area, employer:)
        assert_equal 2, InternshipOfferArea.where(employer_id: employer.id).count
        sign_in(employer)
        params = {
          commit: 'Valider'
        }
        assert_difference 'InternshipOfferArea.count', -1 do
          delete(
            dashboard_internship_offer_area_path(new_area), params: params
          )
        end
        assert_redirected_to dashboard_internship_offer_areas_path
      end

      test 'DELETE current area does not work' do
        employer = create(:employer)
        assert_equal 1, employer.internship_offer_areas.count
        current_area = employer.current_area

        sign_in(employer)
        params = {
          commit: 'Valider'
        }
        assert_difference 'InternshipOfferArea.count', 0 do
          delete(
            dashboard_internship_offer_area_path(current_area), params: params
          )
        end

        assert_redirected_to root_path
      end
    end
  end
end
