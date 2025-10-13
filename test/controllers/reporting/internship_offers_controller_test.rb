# frozen_string_literal: true

require 'test_helper'

module Reporting
  class InternshipOffersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      travel_to Date.new(2023, 10, 1) do
        @sector_agri = Sector.find_by(name: 'Agriculture')
        @sector_wood = Sector.find_by(name: 'Filiere bois')
        @student_male2 = create(:student, :registered_with_phone, :male)
        @student_male1 = create(:student, :registered_with_phone, :male)
        @student_female1 = create(:student, :registered_with_phone, :female)
        @group_with_no_offer = create(:group, name: 'no offer', is_public: false)
        # 3 private offers in agriculture sector, one of which is discarded
        # 1 private offer in wood sector

        # internship_offer_agri_0 is discarded
        @internship_offer_agri_0 = create(:weekly_internship_offer_3eme,
                                          :private,
                                          sector: @sector_agri,
                                          max_candidates: 1,
                                          discarded_at: Date.today)
        @internship_offer_agri_1 = create(:weekly_internship_offer_3eme,
                                          :private,
                                          sector: @sector_agri,
                                          max_candidates: 1)
        @internship_offer_agri_2 = create(:weekly_internship_offer_3eme,
                                          :private,
                                          sector: @sector_agri,
                                          max_candidates: 1)
        @internship_offer_wood = create(:weekly_internship_offer_3eme,
                                        :private,
                                        sector: @sector_wood,
                                        max_candidates: 10)
        # 2 applications on the first offer, 1 on the second
        # 1 approved application on the first offer
        create(:weekly_internship_application,
               :submitted,
               internship_offer: @internship_offer_agri_1,
               student: @student_female1)
        create(:weekly_internship_application,
               :submitted,
               internship_offer: @internship_offer_agri_1,
               student: @student_male1)
        create(:weekly_internship_application,
               :submitted,
               internship_offer: @internship_offer_agri_2,
               student: @student_male2)
        create(:weekly_internship_application,
               :approved,
               internship_offer: @internship_offer_agri_1,
               student: @student_male2)
      end
    end

    test 'GET #index not logged fails' do
      get reporting_internship_offers_path
      assert_response 302
    end

    test 'GET #index as GOD success and has a page title' do
      god = create(:god)
      sign_in(god)
      create(:weekly_internship_offer_2nde)
      get reporting_internship_offers_path
      assert_response :success
      assert_select 'title', 'Statistiques des offres | 1Élève1Stage'
    end

    test 'GET #index as statistician success ' \
         'when department params match his departement_name' do
      statistician = create(:prefecture_statistician)
      department_name = statistician.department_name # ==> Oise
      create(:weekly_internship_offer_2nde, :public, zipcode: '60000') # ==> public
      sign_in(statistician)

      get reporting_internship_offers_path(department: department_name, is_public: false)
      assert_response :success
      total_report = retrieve_html_value('test-total-report', 'test-total-applications', response)
      assert_equal 0, total_report.to_i

      Reporting::InternshipOffer.stub :by_department, Reporting::InternshipOffer.where(discarded_at: nil) do
        get reporting_internship_offers_path(department: department_name)
        assert_response :success

        assert_equal 2, retrieve_html_value('test-total-report', 'test-total-applications', response)
        assert_equal 4, retrieve_html_value('test-total-applications', 'test-total-male-applications', response)
        assert_equal 3, retrieve_html_value('test-total-male-applications', 'test-total-female-applications', response)
        assert_equal 1, retrieve_html_value('test-total-female-applications', 'test-approved-applications', response)
        assert_equal 0, retrieve_html_value('test-total-no-gender-applications', 'test-approved-applications', response)
        assert_equal 1, retrieve_html_value('test-male-approved-applications', 'test-approved-applications', response)
        assert_equal 0,
                     retrieve_html_value('test-female-approved-applications', 'test-male-approved-applications',
                                         response)
        assert_equal 0,
                     retrieve_html_value('test-no-gender-approved-applications', 'test-male-approved-applications',
                                         response)

        get reporting_internship_offers_path(department: department_name, dimension: 'group')
        assert_response :success
        assert_equal 1, retrieve_html_value('test-total-report', 'test-total-applications', response)
        assert_equal '4', css_select('tfoot td.test-total-applications').first.text
        assert_equal '3', css_select('tfoot td.test-total-male-applications').first.text
        assert_equal '1', css_select('tfoot td.test-total-female-applications').first.text
        assert_equal '1', css_select('tfoot td.test-approved-applications').first.text
        assert_equal '0', css_select('tfoot td.test-total-no-gender-applications').first.text
        assert_equal '1', css_select('tfoot td.test-male-approved-applications').first.text
        assert_equal '0', css_select('tfoot td.test-female-approved-applications').first.text
        assert_equal '0', css_select('tfoot td.test-no-gender-approved-applications').first.text
        # null
        assert_equal 0, retrieve_html_value('test-total-report-null', 'test-total-applications', response)
        assert_equal 0, retrieve_html_value('test-total-applications-null', 'test-total-male-applications', response)
        assert_equal 0,
                     retrieve_html_value('test-total-male-applications-null', 'test-total-female-applications',
                                         response)
        assert_equal 0,
                     retrieve_html_value('test-total-female-applications-null', 'test-approved-applications', response)
        assert_equal 0,
                     retrieve_html_value('test-approved-applications-null', 'test-custom-track-approved-applications',
                                         response)
        assert_equal 0,
                     retrieve_html_value('test-male-approved-applications-null', 'test-approved-applications', response)
        assert_equal 0,
                     retrieve_html_value('test-female-approved-applications-null', 'test-male-approved-applications',
                                         response)
        assert_equal 0,
                     retrieve_html_value('test-no-gender-approved-applications-null',
                                         'test-male-approved-applications', response)

        get reporting_internship_offers_path(department: department_name, is_public: false, dimension: 'group')
        assert_response :success
        assert_equal 12, retrieve_html_value('test-total-report', 'test-total-applications', response)
        assert_equal 4, retrieve_html_value('test-total-applications', 'test-total-male-applications', response)
        assert_equal 3, retrieve_html_value('test-total-male-applications', 'test-total-female-applications', response)
        assert_equal 1, retrieve_html_value('test-total-female-applications', 'test-approved-applications', response)
        assert_equal 0, retrieve_html_value('test-total-no-gender-applications', 'test-approved-applications', response)
        assert_equal 1, retrieve_html_value('test-male-approved-applications', 'test-approved-applications', response)
        assert_equal 0,
                     retrieve_html_value('test-female-approved-applications', 'test-male-approved-applications',
                                         response)
        assert_equal 0,
                     retrieve_html_value('test-no-gender-approved-applications', 'test-male-approved-applications',
                                         response)
        assert_select('test-total-report-null', false)
        assert_select('test-total-applications-null', false)
        assert_select('test-total-male-applications-null', false)
        assert_select('test-total-female-applications-null', false)
        assert_select('test-total-no-gender-applications-null', false)
        assert_select('test-approved-applications-null', false)
        assert_select('test-male-approved-applications-null', false)
        assert_select('test-female-approved-applications-null', false)
        assert_select('test-no-gender-approved-applications-null', false)
      end
    end

    test 'GET #index.xlsx as statistician success when department params match his departement_name' do
      # skip 'leak suspicion'
      god = create(:god)
      create(:weekly_internship_offer_2nde)
      create(:api_internship_offer_2nde)
      sign_in(god)

      {
        group: :index_stats,
        sector: :index_stats
      }.each_pair do |dimension, template|
        get(reporting_internship_offers_path(dimension:,
                                             school_year: Date.today.year,
                                             format: :xlsx))
        assert_response :success
        assert_template template
      end
    end

    test 'GET call async Job as god success ' \
         'when department params match his departement_name' do
      god = create(:god)
      create(:weekly_internship_offer_2nde)
      create(:api_internship_offer_2nde)
      sign_in(god)

      get(reporting_internship_offers_path(dimension: 'offers',
                                           format: :xlsx,
                                           school_year: 2019,
                                           department: 'Paris'))
      assert_response 302
      assert_redirected_to reporting_dashboards_path(department: 'Paris', school_year: 2019)
    end

    test 'GET #index as statistician fails ' \
         'when department params does not match his department' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_internship_offers_path(department: 'Ain')
      assert_response 302
    end

    test 'GET #index as operator works' do
      user_operator = create(:user_operator)
      sign_in(user_operator)
      get reporting_internship_offers_path(department: 'Ain')
      assert_response 200
    end

    # This helper method retrieves the figures in front of class1,
    # class2 being just a delimiter
    def retrieve_html_value(class1, class2, response)
      regex = Regexp.new("#{class1}\">(.*)</td>.*#{class2}")
      assert_match(regex, response.body)
      response.body.match(regex).captures.first.to_i
    end
  end
end
