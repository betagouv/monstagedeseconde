# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'GET index not logged redirects to sign in' do
    get account_path
    assert_redirected_to user_session_path
  end

  test 'GET index as Student' do
    student = create(:student)
    sign_in(student)
    get account_path
    assert_template 'users/edit'
    assert_select 'form[action=?]', account_path
  end

  test 'GET index as Operator' do
    operator = create(:user_operator)
    sign_in(operator)
    get account_path
    assert_select '#api-panel', 1
    assert_select 'input[name="user[api_token]"]'
    assert_select "input[value=\"#{operator.api_token}\"]"
  end

  test 'GET account_path(section: identity) as Operator' do
    operator = create(:user_operator)
    sign_in(operator)
    get account_path
    assert_select '#api-panel', 1
    assert_select 'select[name="user[department]"]'
  end

  test 'GET account_path(section: :school) as SchoolManagement' do
    school = create(:school, :with_school_manager)
    [school.school_manager,
     create(:main_teacher, school:),
     create(:teacher, school:),
     create(:other, school:)].each do |role|
      sign_in(role)
      get account_path(section: 'school')
    end
  end

  test 'GET account_path(section: :identiy) as SchoolManagement can change identity' do
    school = create(:school, :with_school_manager)
    [
      create(:main_teacher, school:),
      create(:teacher, school:),
      create(:other, school:)
    ].each do |role|
      sign_in(role)
      get account_path(section: 'identity')
      assert_template 'users/_edit_identity'
      assert_select 'select[name="user[role]"]'
    end
  end

  test 'GET account_path(section: :identity) as main_teacher when removed from school' do
    school = create(:school, :with_school_manager)
    main_teacher = create(:main_teacher, school:)
    main_teacher.school = nil
    main_teacher.save!

    sign_in(main_teacher)
    get account_path(section: 'identity')
    assert_redirected_to account_path(section: :school)
  end

  test 'No other role than operator should have an API token' do
    student = create(:student)
    sign_in(student)
    get account_path
    assert_select "a[href='#{account_path(section: 'api')}']", false
  end

  test 'GET edit render :edit success with all roles' do
    school = create(:school)
    class_room_1 = create(:class_room, school:)
    class_room_2 = create(:class_room, school:)
    [
      create(:school_manager, school:),
      create(:student),
      create(:main_teacher, school:, class_room: class_room_1),
      create(:teacher, school:, class_room: class_room_2),
      create(:other, school:)
    ].each do |role|
      sign_in(role)
      get account_path(section: 'identity')
      assert_response :success, "#{role.type} should have access to edit himself"
      assert_template 'users/_edit_identity'
      assert_select 'form[action=?]', account_path
    end
  end

  test 'GET edit render as Statistician shows a readonly input on email' do
    statistician = create(:statistician)

    sign_in(statistician)
    get account_path(section: 'identity')

    assert_select 'input[name="user[email]"][readonly="readonly"]'
  end

  test 'PATCH edit as employer, updates banners' do
    employer = create(:employer, banners: {})
    sign_in(employer)

    assert_changes -> { employer.reload.banners.key?('background') } do
      patch(account_path, params: { user: { banners: { background: true } } })
      assert_response :found
    end
  end

  test 'PATCH edit as student, updates resume params' do
    student = create(:student)
    sign_in(student)

    patch(account_path, params: {
            user: {
              resume_other: 'other',
              resume_languages: 'languages',
              phone: '+330665656540'
            }
          })

    assert_redirected_to account_path
    student.reload
    assert_equal 'other', student.resume_other
    assert_equal 'languages', student.resume_languages
    assert_equal '+330665656540', student.phone
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'PATCH edit as student registered by phone, add an email' do
    destination_email = 'origin@to.com'
    student = create(:student, email: nil, phone: '+330637607756')
    sign_in(student)

    patch(account_path, params: { user: { email: destination_email } })

    assert_redirected_to account_path
    student.reload
    assert true, student.confirmed?
  end

  test 'PATCH edit as student cannot nullify his email' do
    student = create(:student, phone: '+330623042585', email: 'test@test.fr')
    sign_in(student)
    original_email = student.email

    patch(account_path, params: { user: { email: '' } })

    assert_equal original_email, student.reload.email
    assert_template 'users/edit'
    assert_select '.fr-alert.fr-alert--error strong', html: 'Courriel'
    assert_select '.fr-alert.fr-alert--error',
                  text: 'Courriel : Il faut conserver un email valide pour assurer la continuité du service'
  end

  test 'PATCH failures does not crashes' do
    student = create(:student)
    student_1 = create(:student, email: 'fourcade.m@gmail.com')

    sign_in(student)

    patch(account_path, params: {
            user: {
              email: student_1.email
            }
          })

    assert_response :bad_request
  end

  test 'PATCH edit as school_manager, can change school' do
    original_school = create(:school)
    school_manager = create(:school_manager, school: original_school)
    sign_in(school_manager)

    school = create(:school)

    patch account_path, params: { user: { school_id: school.id,
                                          first_name: 'Jules',
                                          last_name: 'Verne' } }

    assert_redirected_to account_path
    school_manager.reload
    assert_equal school.id, school_manager.school_id
    assert_equal 'Jules', school_manager.first_name
    assert_equal 'Verne', school_manager.last_name
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Etablissement mis à jour avec succès.' }, 1
  end

  test 'PATCH edit as school_manager, can change phone number' do
    original_school = create(:school)
    school_manager = create(:school_manager, school: original_school)
    some_phone_number = '0623042585'
    assert_nil school_manager.phone
    sign_in(school_manager)

    patch account_path, params: { user: {
      phone_prefix: '+33',
      phone_suffix: some_phone_number
    } }

    assert_redirected_to account_path
    school_manager.reload
    assert_equal "+33#{some_phone_number}", school_manager.phone
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'PATCH edit as employer, can change phone number' do
    employer = create(:employer)
    some_phone_number = '0623042585'
    assert_nil employer.phone
    sign_in(employer)

    patch account_path, params: {
      user: {
        phone_prefix: '+33',
        phone_suffix: some_phone_number
      }
    }

    assert_redirected_to account_path
    employer.reload
    assert_equal "+33#{some_phone_number}", employer.phone
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'PATCH edit as employer, can nullify her phone number' do
    some_phone_number = '+330623042585'
    employer = create(:employer, phone: some_phone_number)
    sign_in(employer)

    patch account_path, params: {
      user: {
        phone_prefix: '+33',
        phone_suffix: ' '
      }
    }

    assert_redirected_to account_path
    employer.reload
    assert_nil employer.phone
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'PATCH edit as student can change class_room_id' do
    school = create(:school)
    student = create(:student, school:)
    class_room = create(:class_room, school:)
    sign_in(student)

    patch account_path, params: { user: { school_id: school.id,
                                          class_room_id: class_room.id,
                                          first_name: 'Jules',
                                          last_name: 'Verne',
                                          birth_date: '2000-01-01' } }

    assert_redirected_to account_path
    student.reload
    assert_equal class_room.id, student.class_room_id
    assert_equal Date.new(2000, 1, 1), student.birth_date
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'PATCH edit as SchoolManagement can change role' do
    school = create(:school, :with_school_manager)
    users = [
      school.school_manager,
      create(:main_teacher, school:),
      create(:teacher, school:),
      create(:other, school:)
    ]
    users.each.with_index do |user_change_role, i|
      sign_in(user_change_role)
      role_before = user_change_role.role
      role_after = (users[i + 1] || users[0]).role

      assert_changes -> { user_change_role.reload.role },
                     from: role_before,
                     to: role_after do
        patch(account_path, params: { user: { role: role_after } })
      end
    end
  end

  test 'PATCH edit as Operator can change department' do
    user_operator = create(:user_operator)
    sign_in(user_operator)

    patch account_path, params: { user: { department: 60 } }

    assert_redirected_to account_path
    user_operator.reload
    assert_equal 60.to_s, user_operator.department
  end

  test 'PATCH edit as main_teacher can change class_room_id' do
    school = create(:school)
    school_manager = create(:school_manager, school:)
    main_teacher = create(:main_teacher, school:)
    class_room = create(:class_room, school:)
    sign_in(main_teacher)

    patch account_path, params: { user: { class_room_id: class_room.id } }

    assert_redirected_to account_path
    main_teacher.reload
    assert_equal class_room.id, main_teacher.class_room_id
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  test 'GET #edit as Employer can change email' do
    sign_in(create(:employer))
    get account_path

    assert_response :success
    assert_select 'input#user_email[required]'
  end

  test 'GET #edit as Employer can change password' do
    sign_in(create(:employer))
    get account_path(section: 'password')

    assert_response :success
    assert_select 'input#user_password[required]'
  end

  test 'PATCH password as Employer can change password' do
    employer = create(:employer)
    sign_in(employer)
    user_params = {
      current_password: employer.password,
      password: 'passw0rd1Max!',
      confirmation_password: 'passw0rd'
    }
    patch account_password_path, params: { user: user_params }

    assert_redirected_to account_path(section: :password)
    employer.reload
    assert true, employer.valid_password?('passw0rd')
    follow_redirect!
    assert_select '#alert-success #alert-text', { text: 'Compte mis à jour avec succès.' }, 1
  end

  # test 'POST resend_confirmation_phone_toke' do
  #   student = create(:student, :registered_with_phone, confirmed_at: nil)
  #   post resend_confirmation_phone_token_path(
  #     format: :turbo_stream,
  #     params: { user: { id: student.id } }
  #   )
  #   assert_response :success
  #   assert_select('#code-request', text: 'Votre code a été renvoyé')
  # end

  test 'POST resend_confirmation_phone_toke fails with wrong data' do
    post resend_confirmation_phone_token_path(
      format: :turbo_stream,
      params: { user: { id: 1 } } # error
    )
    assert_response :success
    assert_select('#code-request', text: "Une erreur est survenue et le code n'a pas été renvoyé")
  end

  # test 'POST resend_confirmation_phone_token' do
  #   student = create(:student, :registered_with_phone, confirmed_at: nil)
  #   post resend_confirmation_phone_token_path(format: :turbo_stream, params: { user: { id: student.id } })
  #   assert_response :success
  #   assert_select('#code-request', text: 'Votre code a été renvoyé')
  # end

  test 'POST resend_confirmation_phone_token fails with wrong data' do
    post resend_confirmation_phone_token_path(format: :turbo_stream, params: { user: { id: 1 } }) # error
    assert_response :success
    assert_select('#code-request', text: "Une erreur est survenue et le code n'a pas été renvoyé")
  end

  test 'PATCH password as Employer fails with weak password' do
    employer = create(:employer)
    sign_in(employer)
    user_params = {
      current_password: employer.password,
      password: 'password123'
    }
    patch account_password_path, params: { user: user_params }

    assert_response :bad_request
  end

  test 'PATCH password as Employer registreed by phone fails with weak password' do
    employer = create(:employer, email: nil, phone: '+330623042585')
    sign_in(employer)
    user_params = {
      current_password: employer.password,
      password: 'password123'
    }
    patch account_password_path, params: { user: user_params }

    assert_response :bad_request
  end
end
