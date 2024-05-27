# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test 'GET #new internship application as student' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student, :with_phone, school: school, class_room: create(:class_room, school: school))
      sign_in(student)

      get(new_internship_offer_internship_application_path(internship_offer))
      assert_response :success
    end

    test 'GET #new internship application as student already applied' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student, school: school, class_room: create(:class_room, school: school))
      create(:weekly_internship_application, internship_offer: internship_offer, student: student)

      sign_in(student)
      get(new_internship_offer_internship_application_path(internship_offer))
      assert_redirected_to root_path
    end

    test 'POST #create internship application as student with email and no phone' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student,
        school: school,
        class_room: create(:class_room, school: school),
        address: '100 bd Victor Hugo 13000 Marseille',
        legal_representative_email: 'sylvie@gmail.com',
        legal_representative_full_name: 'Sylvie Dupont',
        legal_representative_phone: '+330600000000'
      )

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
          student_legal_representative_phone: '+330600990099'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
      assert_equal student.id, created_internship_application.student.id

      student = student.reload
      assert_equal '+330656565600', created_internship_application.student_phone

      assert_equal created_internship_application.student_email, 'newemail@gmail.com'

      puts student.legal_representative_email
      # byebug
      assert_equal 'parent@gmail.com', student.reload.legal_representative_email
      assert_equal created_internship_application.student_legal_representative_email, 'parent@gmail.com'

      assert_equal student.legal_representative_full_name, 'Jean Dupont'
      assert_equal created_internship_application.student_legal_representative_full_name, 'Jean Dupont'

      assert_equal student.legal_representative_phone, '+330600990099'
      assert_equal created_internship_application.student_legal_representative_phone, '+330600990099'

      refute_equal student.email, 'newemail@gmail.com' # unchanged
      assert_equal student.phone, '+330656565600' # changed with student_phone
    end

    test 'POST #create internship application as student with phone and no email' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student,
        school: school,
        phone: '+330600110011',
        email: nil,
        class_room: create(:class_room, school: school),
        address: '100 bd Victor Hugo 13000 Marseille',
        legal_representative_email: 'sylvie@gmail.com',
        legal_representative_full_name: 'Sylvie Dupont',
        legal_representative_phone: '+330600000000'
      )

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
          student_legal_representative_phone: '+330600990099'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
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

      assert_equal student.email, 'newemail@gmail.com' # changed with student_email
      refute_equal student.phone, '+330656565600' # unchanged with student_phone
    end

    test 'POST #create internship application as student with phone and blank email' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student,
        school: school,
        phone: '+330600110011',
        email: '',
        class_room: create(:class_room, school: school),
        address: '100 bd Victor Hugo 13000 Marseille',
        legal_representative_email: 'sylvie@gmail.com',
        legal_representative_full_name: 'Sylvie Dupont',
        legal_representative_phone: '+330600000000'
      )

      assert_equal student.email, nil
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
          student_legal_representative_phone: '+330600990099'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
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

      assert_equal student.email, 'newemail@gmail.com' # changed with student_email
      refute_equal student.phone, '+330656565600' # unchanged with student_phone
    end

    test 'POST #create internship application as student to offer posted by statistician' do
      internship_offer = create(:weekly_internship_offer)
      internship_offer.update(employer_id: create(:statistician).id)
      school = create(:school)
      student = create(:student, school: school, class_room: create(:class_room, school: school))
      sign_in(student)
      valid_params = {
        internship_application: {
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400',
          }
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
      assert_equal student.id, created_internship_application.student.id

      student = student.reload
      assert_equal '+330656565400', student.phone
    end

    test 'POST #create internship application as student without class_room' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student, school: school)
      sign_in(student)
      valid_params = {
        internship_application: {
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400'
          }
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
      assert_equal student.id, created_internship_application.student.id

      student = student.reload
      assert_equal '+330656565400', student.phone
    end

    # create internship application as student with class_room and check that counter are updated
    test 'POST #create internship application as student with greater max_candidates than hosting_info' do
      internship_offer = create(:weekly_internship_offer,
        max_candidates: 3)
      internship_offer.hosting_info.update(max_candidates: 3)

      school = create(:school)
      class_room = create(:class_room, school: school)
      student_1 = create(:student, school: school, class_room: class_room)
      student_2 = create(:student, school: school, class_room: class_room)

      a1 = create(:weekly_internship_application,
        :approved,
        internship_offer: internship_offer,
        student: student_1,
      )

      sign_in(student_2)

      valid_params = {
        internship_application: {
          motivation: 'Je suis trop motivé wesh',
          user_id: student_2.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400'
          }
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do # no failure since validation is not run
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end
    end

    test 'POST #create internship application as student with empty phone in profile' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student, school: school, phone: nil, email: 'marc@ms3e.fr', class_room: create(:class_room, school: school))
      sign_in(student)
      valid_params = {
        internship_application: {
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          student_email: 'julie@ms3e.fr',
          student_phone: '+330600119988'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      student = student.reload
      assert_equal '+330600119988', created_internship_application.student_phone
      assert_equal 'julie@ms3e.fr', created_internship_application.student_email
      assert_equal '+330600119988', student.phone # changed
      assert_equal 'marc@ms3e.fr', student.email # unchanged
    end

    test 'POST #create internship application as student with empty email in profile' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student, school: school, phone: '+330600110011', email: nil, class_room: create(:class_room, school: school))
      sign_in(student)
      valid_params = {
        internship_application: {
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          student_email: 'marc@ms3e.fr',
          student_phone: '0600000000'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      student = student.reload
      assert_equal '0600000000', created_internship_application.student_phone
      assert_equal 'marc@ms3e.fr', created_internship_application.student_email
      assert_equal '+330600110011', student.phone # unchanged
      assert_equal 'marc@ms3e.fr', student.email # changed
    end

    test 'POST #create internship application as student with duplicate contact email' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student, school: school, phone: '+330600110011', email: nil, class_room: create(:class_room, school: school))
      student_2 = create(:student, :with_phone)
      sign_in(student)
      valid_params = {
        internship_application: {
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          student_email: student_2.email,
          student_phone: '0600000000'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 0) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_response :bad_request
      end
    end

    test 'POST #create internship application as student with duplicate contact phone' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school)
      student = create(:student, school: school, phone: '+330600110011', class_room: create(:class_room, school: school))
      student_2 = create(:student, phone: '+330600110022')
      sign_in(student)
      valid_params = {
        internship_application: {
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          student_email: student.email,
          student_phone: student_2.phone.gsub('+33', '')
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 0) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_response :bad_request
      end
    end
  end
end
