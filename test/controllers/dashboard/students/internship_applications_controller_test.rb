# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Students
    class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test 'GET internship_applications#index not connected responds with redireciton' do
        student = create(:student)
        get dashboard_students_internship_applications_path(student)
        assert_response :redirect
      end

      test 'GET internship_applications#index as another student responds with redireciton' do
        student_1 = create(:student)
        sign_in(student_1)
        get dashboard_students_internship_applications_path(create(:student))
        assert_response :redirect
      end

      test 'GET internship_applications#index as student.school.school_manager responds with 200' do
        school = create(:school)
        class_room = create(:class_room, school:)
        student = create(:student, school:, class_room:)
        school_manager = create(:school_manager, school:)
        sign_in(school_manager)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'title', 'Mes candidatures | 1Elève1Stage'
        assert_select 'h1.h2.mb-3', text: student.name
        assert_select 'a[href=?]', dashboard_school_class_room_students_path(school, class_room)
        assert_select 'h2.h4', text: 'Aucun stage'
      end

      test 'GET internship_applications#index as student.school.school_manager works and show convention button' do
        school = create(:school)
        class_room = create(:class_room, school:)
        student = create(:student, school:, class_room:)
        school_manager = create(:school_manager, school:)
        internship_application = create(:weekly_internship_application, :approved, student:)
        sign_in(school_manager)
        get dashboard_students_internship_applications_path(student_id: student.id)
        assert_response :success
        assert_select 'a[href=?]',
                      dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                             uuid: internship_application.uuid, transition: :signed!)
        assert_select '.fr-badge.fr-badge--no-icon.fr-badge--success', text: 'stage validé'
      end

      test 'GET internship_applications#index as SchoolManagement works and show convention button' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school:)
        student = create(:student, school:, class_room:)
        main_teacher = create(:main_teacher, school:, class_room:)
        internship_application = create(:weekly_internship_application, :approved, student:)
        sign_in(main_teacher)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'a[href=?]',
                      dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                             uuid: internship_application.uuid, transition: :signed!)
        assert_select '.fr-badge.fr-badge--no-icon.fr-badge--success', text: 'stage validé'
      end

      test 'GET internship_applications#index render navbar, timeline' do
        student = create(:student)
        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_template 'dashboard/students/internship_applications/index'
        assert_select 'h1.h2', text: 'Mes candidatures'
        assert_select 'h2.h4', text: 'Aucun stage'
        assert_select 'a.fr-btn[href=?]', student.presenter.default_internship_offers_path
      end

      test 'GET internship_applications#index render internship_applications' do
        student = create(:student, phone: '+5940611223344')
        states = %i[submitted
                    approved
                    expired
                    validated_by_employer
                    rejected
                    canceled_by_employer
                    canceled_by_student]
        internship_applications = states.each_with_object({}) do |state, accu|
          accu[state] = create(:weekly_internship_application, state, student:)
        end

        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select '.fr-badge.fr-badge--no-icon.fr-badge--purple-glycine', text: 'annulée', count: 1
        assert_select '.fr-badge.fr-badge--no-icon.fr-badge--error', text: 'expirée', count: 1
        assert_select '.fr-badge.fr-badge--no-icon.fr-badge--success', text: 'stage validé', count: 1
        assert_select '.fr-badge.fr-badge--no-icon.fr-badge--error', text: "annulée par l'employeur", count: 1
        assert_select '.fr-badge.fr-badge--no-icon.fr-badge--warning', text: "refusée par l'employeur", count: 1
        assert_select '.fr-badge.fr-badge--no-icon.fr-badge--info', text: "Sans réponse de l'entreprise", count: 1
      end

      test 'GET internship_applications#show not connected responds with redirection' do
        student = create(:student)
        internship_application = create(:weekly_internship_application, student:)
        get dashboard_students_internship_applications_path(student_id: student.id,
                                                            uuid: internship_application.uuid)
        assert_response :redirect
      end

      test 'GET internship_applications#show render navbar' do
        student = create(:student)
        sign_in(student)
        internship_application = create(:weekly_internship_application, {
                                          student:,
                                          aasm_state: :approved,
                                          convention_signed_at: 1.days.ago,
                                          approved_at: 1.days.ago,
                                          validated_by_employer_at: 1.days.ago,
                                          submitted_at: 2.days.ago
                                        })

        get dashboard_students_internship_application_path(student_id: student.id,
                                                           uuid: internship_application.uuid)
        assert_response :success

        assert_template 'dashboard/students/internship_applications/show'
        assert_select '.fr-badge.fr-badge--no-icon.fr-badge--success', text: 'stage validé'
      end

      test 'GET internship_applications#show with submitted application' do
        student = create(:student)
        sign_in(student)
        internship_application = create(:weekly_internship_application, student:)

        get dashboard_students_internship_application_path(student_id: student.id,
                                                           uuid: internship_application.uuid)
        assert_response :success
        assert_select '.fr-badge.fr-badge--no-icon', text: "Sans réponse de l'entreprise"
      end

      test '#resend_application' do
        student = create(:student)
        sign_in(student)
        internship_application = create(
          :weekly_internship_application,
          :submitted,
          student:
        )
        assert_changes -> { internship_application.reload.dunning_letter_count } do
          post resend_application_dashboard_students_internship_application_path(
            student_id: internship_application.student.id,
            uuid: internship_application.uuid
          ), params: {}
        end
        assert_equal 1, internship_application.reload.dunning_letter_count
        assert_no_changes -> { internship_application.reload.dunning_letter_count } do
          post resend_application_dashboard_students_internship_application_path(
            student_id: internship_application.student.id,
            id: internship_application.id
          ), params: {}
        end
        assert_redirected_to dashboard_students_internship_applications_path(student)
      end

      test '#show with a magic link' do
        student = create(:student)
        sgid = ''
        internship_application = create(:weekly_internship_application, student:)
        travel_to Time.now - 3.month do
          sgid = student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
          get dashboard_students_internship_application_path(
            sgid:,
            student_id: student.id,
            uuid: internship_application.uuid
          )
          assert_equal 1, internship_application.reload.magic_link_tracker
        end
        travel_to Time.now do
          get dashboard_students_internship_application_path(
            sgid:,
            student_id: student.id,
            uuid: internship_application.uuid
          )
          assert_redirected_to dashboard_students_internship_application_path(
            student_id: student.id,
            uuid: internship_application.uuid
          )
          assert_equal 2, internship_application.reload.magic_link_tracker
        end
      end

      test 'student cannot validate his own application' do
        internship_application = create(:weekly_internship_application, :submitted, student: create(:student))
        sign_in(internship_application.student)
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            uuid: internship_application.uuid
          ),
          params: { transition: :employer_validate }
        )
        refute internship_application.reload.validated_by_employer?
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            uuid: internship_application.uuid
          ),
          params: { transition: :approve }
        )
        refute internship_application.reload.approved?
      end
    end
  end
end
