# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper
    include ThirdPartyTestHelpers

    test 'GET #new internship application as student with no former responsible details' do
      travel_to Time.zone.local(2025, 3, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school)
        student = create(:student,
                         :with_phone,
                         school:,
                         class_room: create(:class_room, school:))
        sign_in(student)

        get(new_internship_offer_internship_application_path(internship_offer))
        assert_response :success
      end
    end

    test 'GET #new internship application as student already applied' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school)
        student = create(:student, school:, class_room: create(:class_room, school:))
        create(:weekly_internship_application, internship_offer:, student:)

        sign_in(student)
        get(new_internship_offer_internship_application_path(internship_offer))
        assert_redirected_to root_path
      end
    end

    test 'GET #new internship application as student with no weeks available redirects to offer path with alert' do
      skip 'leak suspicion'
      travel_to Time.zone.local(2025, 3, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school, school_type: 'college')
        week = Week.selectable_on_school_year.first # first week of school year, in the past
        school.weeks << week
        student = create(:student, school:, class_room: create(:class_room, school:))
        sign_in(student)

        get(new_internship_offer_internship_application_path(internship_offer))
        assert_redirected_to internship_offer_path(internship_offer),
                             alert: "Votre établissement a déclaré des semaines de stage et aucune semaine n'est compatible avec cette offre de stage."
      end
    end

    test 'GET #new internship application as student with no weeks set by the school works' do
      travel_to Time.zone.local(2025, 3, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school, school_type: 'college')
        school.weeks = []
        student = create(:student, school:, class_room: create(:class_room, school:))
        sign_in(student)

        get(new_internship_offer_internship_application_path(internship_offer))
        assert_response :success
        assert_select 'p.test-missing-school-weeks',
                      text: "Attention, vérifiez bien que les dates de stage proposées dans l'annonce correspondent à vos dates de stage. Votre chef d'établissement n'a en effet pas renseigné les semaines de stage de votre établissement."
      end
    end

    test 'POST #create internship application as student with email and no phone' do
      travel_to Time.zone.local(2025, 3, 1) do
        weeks = SchoolTrack::Troisieme.selectable_on_school_year_weeks
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school, school_type: 'college', weeks: weeks)
        student = create(:student,
                         :troisieme,
                         school:,
                         class_room: create(:class_room, school:),
                         address: '100 bd Victor Hugo 13000 Marseille',
                         legal_representative_email: 'sylvie@gmail.com',
                         legal_representative_full_name: 'Sylvie Dupont',
                         legal_representative_phone: '+330600000000')

        assert_nil student.phone

        sign_in(student)
        valid_params = {
          internship_application: {
            motivation: 'Je suis trop motivé wesh',
            user_id: student.id,
            internship_offer_id: internship_offer.id,
            internship_offer_type: InternshipOffer.name,
            type: InternshipApplications::WeeklyFramed.name,
            student_email: 'newemail@gmail.com',
            student_phone: '+330656565600',
            student_address: '1 rue de la paix 75001 Paris',
            student_legal_representative_full_name: 'Jean Dupont',
            student_legal_representative_email: 'parent@gmail.com',
            student_legal_representative_phone: '+330600990099',
            week_ids: [weeks.first.id]
          }
        }

        assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
          post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
          assert_redirected_to dashboard_students_internship_applications_path(
            student_id: student.id,
            notice_banner: true
          )
        end

        created_internship_application = InternshipApplications::WeeklyFramed.last
        assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation
        assert_equal student.id, created_internship_application.student.id

        student = student.reload
        assert_equal '+330656565600', created_internship_application.student_phone

        assert_equal created_internship_application.student_email, 'newemail@gmail.com'

        puts student.legal_representative_email
        assert_equal 'parent@gmail.com', student.reload.legal_representative_email
        assert_equal created_internship_application.student_legal_representative_email, 'parent@gmail.com'

        assert_equal student.legal_representative_full_name, 'Jean Dupont'
        assert_equal created_internship_application.student_legal_representative_full_name, 'Jean Dupont'

        assert_equal student.legal_representative_phone, '+330600990099'
        assert_equal created_internship_application.student_legal_representative_phone, '+330600990099'

        refute_equal student.email, 'newemail@gmail.com' # unchanged
        assert_equal '+330656565600', student.phone
      end
    end

    test 'POST #create internship application as student with phone and no email' do
      travel_to Time.zone.local(2025, 3, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        weeks = SchoolTrack::Troisieme.selectable_on_school_year_weeks
        school = create(:school, :college, weeks: weeks)
        student = create(:student,
                         school:,
                         phone: '+330600110011',
                         email: nil,
                         class_room: create(:class_room, school:),
                         address: '100 bd Victor Hugo 13000 Marseille',
                         legal_representative_email: 'sylvie@gmail.com',
                         legal_representative_full_name: 'Sylvie Dupont',
                         legal_representative_phone: '+330600000000')

        assert_nil student.email
        refute_nil student.phone

        sign_in(student)
        valid_params = {
          internship_application: {
            motivation: 'Je suis trop motivé wesh',
            user_id: student.id,
            internship_offer_id: internship_offer.id,
            internship_offer_type: InternshipOffer.name,
            type: InternshipApplications::WeeklyFramed.name,
            student_email: 'newemail@gmail.com',
            student_phone: '+330656565600',
            student_address: '1 rue de la paix 75001 Paris',
            student_legal_representative_full_name: 'Jean Dupont',
            student_legal_representative_email: 'parent@gmail.com',
            student_legal_representative_phone: '+330600990099',
            week_ids: [weeks.second.id]
          }
        }

        assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
          post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
          assert_redirected_to dashboard_students_internship_applications_path(
            student_id: student.id,
            notice_banner: true
          )
        end

        created_internship_application = InternshipApplications::WeeklyFramed.last
        assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation
        assert_equal student.id, created_internship_application.student.id

        student = student.reload
        assert_equal '+330656565600', created_internship_application.student_phone

        assert_equal created_internship_application.student_email, 'newemail@gmail.com'

        assert_equal 'parent@gmail.com', student.reload.legal_representative_email
        assert_equal created_internship_application.student_legal_representative_email, 'parent@gmail.com'

        assert_equal student.legal_representative_full_name, 'Jean Dupont'
        assert_equal created_internship_application.student_legal_representative_full_name, 'Jean Dupont'

        assert_equal student.legal_representative_phone, '+330600990099'
        assert_equal created_internship_application.student_legal_representative_phone, '+330600990099'

        assert_equal 'newemail@gmail.com', student.email # unchanged with student_email
        assert_equal '+330656565600', student.phone # unchanged with student_phone
      end
    end

    test 'POST #create internship application as student with phone and blank email' do
      travel_to Time.zone.local(2025, 3, 1) do
        weeks = Week.selectable_on_school_year
        internship_offer = create(:weekly_internship_offer_3eme, weeks: weeks)
        valid_phone_number = '0656565600'
        school = create(:school, :college, weeks: weeks)
        assert school.weeks == weeks
        student = create(:student,
                         :troisieme,
                         :registered_with_phone,
                         school:,
                         class_room: create(:class_room, school:),
                         address: '100 bd Victor Hugo 13000 Marseille',
                         legal_representative_email: 'sylvie@gmail.com',
                         legal_representative_full_name: 'Sylvie Dupont',
                         legal_representative_phone: '+330600000000')

        assert_nil student.email
        refute_nil student.phone

        sign_in(student)
        valid_params = {
          internship_application: {
            motivation: 'Je suis trop motivé wesh',
            user_id: student.id,
            internship_offer_id: internship_offer.id,
            internship_offer_type: InternshipOffer.name,
            type: InternshipApplications::WeeklyFramed.name,
            student_email: 'newemail@gmail.com',
            student_phone: valid_phone_number,
            student_address: '1 rue de la paix 75001 Paris',
            student_legal_representative_full_name: 'Jean Dupont',
            student_legal_representative_email: 'parent@gmail.com',
            student_legal_representative_phone: '+330600990099',
            week_ids: [weeks.last.id]
          }
        }

        assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
          post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
          assert_redirected_to dashboard_students_internship_applications_path(
            student_id: student.id,
            notice_banner: true
          )
        end

        created_internship_application = InternshipApplications::WeeklyFramed.last
        assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation
        assert_equal student.id, created_internship_application.student.id

        student = student.reload
        assert_equal '0656565600', created_internship_application.student_phone

        assert_equal 'newemail@gmail.com', created_internship_application.student_email

        assert_equal 'parent@gmail.com', student.reload.legal_representative_email
        assert_equal created_internship_application.student_legal_representative_email, 'parent@gmail.com'

        assert_equal student.legal_representative_full_name, 'Jean Dupont'
        assert_equal created_internship_application.student_legal_representative_full_name, 'Jean Dupont'

        assert_equal student.legal_representative_phone, '+330600990099'
        assert_equal created_internship_application.student_legal_representative_phone, '+330600990099'

        assert_nil student.email # unchanged
        refute_equal student.phone, '+330656565600' # unchanged with student_phone
      end
    end

    test 'POST #create internship application as student to offer posted by statistician' do
      travel_to Time.zone.local(2025, 3, 1) do
        weeks = SchoolTrack::Troisieme.selectable_on_school_year_weeks
        internship_offer = create(:weekly_internship_offer_3eme, weeks:)
        internship_offer.update(employer_id: create(:statistician).id)
        school = create(:school, :college, weeks:)
        student = create(:student, school:, class_room: create(:class_room, school:))
        sign_in(student)
        valid_params = {
          internship_application: {
            motivation: 'Je suis trop motivé wesh',
            user_id: student.id,
            internship_offer_id: internship_offer.id,
            internship_offer_type: InternshipOffer.name,
            type: InternshipApplications::WeeklyFramed.name,
            week_ids: weeks.third.id,
            student_phone: '+330656565400',
            student_email: 'test@free.fr'
          }
        }

        assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
          post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
          assert_redirected_to dashboard_students_internship_applications_path(
            student_id: student.id,
            notice_banner: true
          )
        end

        created_internship_application = InternshipApplications::WeeklyFramed.last
        assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation
        assert_equal student.id, created_internship_application.student.id

        student = student.reload
        assert_equal '+330656565400', student.phone
      end
    end

    test 'POST #create internship application as student without class_room' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school)
        student = create(:student, school:)
        sign_in(student)
        valid_params = {
          internship_application: {
            motivation: 'Je suis trop motivé wesh',
            user_id: student.id,
            internship_offer_id: internship_offer.id,
            internship_offer_type: InternshipOffer.name,
            type: InternshipApplications::WeeklyFramed.name,
            student_phone: '+330656565400',
            student_email: 'test@free.fr',
            week_ids: [internship_offer.weeks.first.id]
          }
        }

        assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
          post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
          assert_redirected_to dashboard_students_internship_applications_path(
            student_id: student.id,
            notice_banner: true
          )
        end

        created_internship_application = InternshipApplications::WeeklyFramed.last
        assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation
        assert_equal student.id, created_internship_application.student.id

        student = student.reload
        assert_equal '+330656565400', student.phone
      end
    end

    test 'POST #create internship application as student with empty phone in profile' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school)
        student = create(:student, school:, phone: nil, email: 'marc@ms3e.fr',
                                   class_room: create(:class_room, school:))
        valid_phone_number = '+330600118899'
        sign_in(student)
        valid_params = {
          internship_application: {
            motivation: 'Je suis trop motivé wesh',
            user_id: student.id,
            internship_offer_id: internship_offer.id,
            internship_offer_type: InternshipOffer.name,
            student_email: 'julie@ms3e.fr',
            student_phone: valid_phone_number,
            week_ids: [internship_offer.weeks.first.id]
          }
        }

        assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
          post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
          assert_redirected_to dashboard_students_internship_applications_path(
            student_id: student.id,
            notice_banner: true
          )
        end

        created_internship_application = InternshipApplications::WeeklyFramed.last
        student = student.reload
        assert_equal valid_phone_number, created_internship_application.student_phone
        assert_equal 'julie@ms3e.fr', created_internship_application.student_email
        assert_equal valid_phone_number, student.phone # changed
        assert_equal 'marc@ms3e.fr', student.email # unchanged
      end
    end

    test 'POST #create internship application as student with empty email in profile' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school)
        student = create(:student, school:, phone: '+330600110011', email: nil,
                                   class_room: create(:class_room, school:))
        sign_in(student)
        valid_params = {
          internship_application: {
            motivation: 'Je suis trop motivé wesh',
            user_id: student.id,
            internship_offer_id: internship_offer.id,
            internship_offer_type: InternshipOffer.name,
            student_email: 'marc@ms3e.fr',
            student_phone: '0600000000',
            week_ids: [internship_offer.weeks.first.id]
          }
        }

        assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
          post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
          assert_redirected_to dashboard_students_internship_applications_path(
            student_id: student.id,
            notice_banner: true
          )
        end

        created_internship_application = InternshipApplications::WeeklyFramed.last
        student = student.reload
        assert_equal '0600000000', created_internship_application.student_phone
        assert_equal 'marc@ms3e.fr', created_internship_application.student_email
        assert_equal '+330600110011', student.phone # unchanged
        assert_nil student.email # unchanged
      end
    end

    test 'POST #create internship application as student with duplicate contact email is rejected' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school)
        student = create(:student, school:, phone: '+330600110011', email: nil,
                                   class_room: create(:class_room, school:))
        student_2 = create(:student, :with_phone)
        sign_in(student)
        valid_params = {
          internship_application: {
            motivation: 'Je suis trop motivé wesh',
            user_id: student.id,
            internship_offer_id: internship_offer.id,
            internship_offer_type: InternshipOffer.name,
            student_email: student_2.email,
            student_phone: '0600000000',
            week_ids: [internship_offer.weeks.first.id]
          }
        }

        assert_no_difference('InternshipApplications::WeeklyFramed.count') do
          post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
          assert_response :bad_request
        end
      end
    end

    test 'POST #create internship application as student with duplicate contact phone is tolerated' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        school = create(:school)
        student = create(:student, school:, phone: '+330600110011',
                                   class_room: create(:class_room, school:))
        student_2 = create(:student, phone: '+330600110022')
        sign_in(student)
        valid_params = {
          internship_application: {
            motivation: 'Je suis trop motivé wesh',
            user_id: student.id,
            internship_offer_id: internship_offer.id,
            internship_offer_type: InternshipOffer.name,
            student_email: student.email,
            student_phone: student_2.phone.gsub('+33', ''),
            week_ids: [internship_offer.weeks.first.id]
          }
        }

        assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
          post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
          assert_response :redirect
        end
      end
    end
  end
end
