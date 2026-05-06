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

      test 'DELETE pure destruction with internship applications anonymizes them' do
        employer = create(:employer)
        area_to_destroy = create(:internship_offer_area, employer:)
        offer = create(:weekly_internship_offer,
                       employer:,
                       internship_offer_area: area_to_destroy)
        application = create(:weekly_internship_application, :submitted,
                             internship_offer: offer)

        sign_in(employer)
        params = { commit: 'Valider' }

        assert_nothing_raised do
          delete(dashboard_internship_offer_area_path(area_to_destroy), params:)
        end

        application.reload
        assert_equal 'NA', application.motivation
        assert_equal 'NA', application.student_address
        assert_equal 'NA', application.student_legal_representative_full_name
        assert_equal 'NA', application.student_legal_representative_email
        assert_equal 'NA', application.student_email
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
