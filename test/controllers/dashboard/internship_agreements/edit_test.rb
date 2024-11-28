# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class EditTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #internship_agreements/edit as visitor redirects to user_session_path' do
      get edit_dashboard_internship_agreement_path(create(:internship_agreement, employer_accept_terms: true).to_param)
      assert_redirected_to new_user_session_path
    end

    test 'GET #internship_agreements/edit as mere teacher redirects to user_session_path' do
      skip 'internship_agreements is not implemented yet to be finished by november 2024'
      school = create(:school, :with_school_manager)
      internship_offer = create(:weekly_internship_offer_3eme, is_public: true, max_candidates: 1)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      class_room = create(:class_room, school: school)
      teacher = create(:teacher, school: school, class_room: class_room)
      internship_agreement = create(:internship_agreement, internship_application: internship_application,
                                                           employer_accept_terms: true)
      sign_in(teacher)

      get edit_dashboard_internship_agreement_path(internship_agreement.id)
      assert_redirected_to root_path
    end

    test 'GET #edit as School Management not owning application student school redirects to user_session_path' do
      school = create(:school, :with_school_manager)
      another_school = create(:school, :with_school_manager)
      internship_offer = create(:weekly_internship_offer_3eme, is_public: true, max_candidates: 1)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      class_room = create(:class_room, school: another_school)
      internship_application.student.update(class_room_id: class_room.id, school_id: another_school.id)
      internship_agreement = create(:internship_agreement, internship_application: internship_application,
                                                           employer_accept_terms: true)
      sign_in(school.school_manager)

      get edit_dashboard_internship_agreement_path(uuid: internship_agreement.uuid)
      assert_redirected_to root_path
    end

    test 'GET #edit as employer owning application student school renders success' do
      school = create(:school, :with_school_manager)
      internship_application = create(:weekly_internship_application, :approved)
      internship_application.student.update(school_id: school.id)
      internship_agreement = create(:internship_agreement, internship_application: internship_application,
                                                           school_manager_accept_terms: true)
      sign_in(school.school_manager)

      get edit_dashboard_internship_agreement_path(uuid: internship_agreement.uuid)
      assert_response :success
    end

    # As Teacher
    test 'GET #edit as teacher if belong to school' do
      internship_agreement = create(:internship_agreement, employer_accept_terms: true)
      sign_in(create(:teacher, school: internship_agreement.internship_application.student.school))
      get edit_dashboard_internship_agreement_path(uuid: internship_agreement.uuid)
      assert_response :success
    end

    # As Main Teacher
    test 'GET #edit as main teacher if belong to school' do
      internship_agreement = create(:internship_agreement, employer_accept_terms: true)
      sign_in(create(:main_teacher, school: internship_agreement.internship_application.student.school))
      get edit_dashboard_internship_agreement_path(uuid: internship_agreement.uuid)
      assert_response :success
    end

    # As Other
    test 'GET #edit as other if belong to school' do
      internship_agreement = create(:internship_agreement, employer_accept_terms: true)
      sign_in(create(:other, school: internship_agreement.internship_application.student.school))
      get edit_dashboard_internship_agreement_path(uuid: internship_agreement.uuid)
      assert_response :success
    end

    # As Admin officer
    test 'GET #edit as admin officer if belong to school' do
      internship_agreement = create(:internship_agreement, employer_accept_terms: true)
      sign_in(create(:admin_officer, school: internship_agreement.internship_application.student.school))
      get edit_dashboard_internship_agreement_path(uuid: internship_agreement.uuid)
      assert_response :success
    end
  end
end
