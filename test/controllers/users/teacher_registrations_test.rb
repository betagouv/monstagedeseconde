# frozen_string_literal: true

require 'test_helper'

class TeacherRegistrationsTest < ActionDispatch::IntegrationTest
  include ThirdPartyTestHelpers

  def assert_teacher_form_rendered
    assert_select 'input', value: 'SchoolManagement', hidden: 'hidden'
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /J'accepte les/
  end

  test 'GET new as a SchoolManagement renders expected inputs' do
    captcha_stub do
      get new_user_registration_path(as: 'SchoolManagement')

      assert_response :success
      assert_select 'title', 'Inscription | Stages de 2de'
      assert_teacher_form_rendered
    end
  end

  test 'POST #create with missing params fails creation' do
    assert_difference('Users::SchoolManagement.teacher.count', 0) do
      post user_registration_path(params: { user: { email: 'teacher@acu.fr',
                                                    password: 'okokok1Max!!',
                                                    type: 'Users::SchoolManagement',
                                                    first_name: 'Martin',
                                                    last_name: 'Fourcade',
                                                    accept_terms: '1' } })
      assert_response 200
      assert_select 'title', 'Création de compte | Stages de 2de'
      assert_teacher_form_rendered
    end
  end

  test 'POST #create with all params create SchoolManagement' do
    school = create(:school)
    school_manager = create(:school_manager, school:)
    class_room = create(:class_room, name: '2de A', school:)
    assert_difference('Users::SchoolManagement.teacher.count', 1) do
      post user_registration_path(params: { user: { email: "teacher@#{school.email_domain_name}",
                                                    password: 'okokok1Max!!',
                                                    type: 'Users::SchoolManagement',
                                                    first_name: 'Martin',
                                                    last_name: 'Fourcade',
                                                    school_id: school.id,
                                                    class_room_id: class_room.id,
                                                    accept_terms: '1',
                                                    role: :teacher } })
      school_teacher_id = Users::SchoolManagement.where(role: 'teacher').last.id
      assert_redirected_to users_registrations_standby_path(id: school_teacher_id)
    end
  end
end
