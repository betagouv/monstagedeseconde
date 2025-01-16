# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'GET works' do
    get new_user_session_path
    assert_response :success
    assert_select 'title', 'Connexion | 1Elève1Stage'
    assert_select '#user_email'
    assert_select '#select-channel-phone'
    assert_select '#user_password[autofocus=autofocus]', count: 0
  end

  test 'GET #new_session with check_confirmation and id params and unconfirmed account' do
    email = 'fourcade.m@gmail.com'
    employer = create(:employer, email:, confirmed_at: nil)
    get new_user_session_path(params: { check_confirmation: true, id: employer.id })
    follow_redirect!
    assert_response :success
    assert_select('.h3', text: 'Confirmez votre compte')
    flash_message = 'Vous trouverez parmi vos emails le message' \
                      ' permettant l\'activation de votre compte'
    assert_select('span#alert-text', text: flash_message) # 1
  end

  test 'GET #new_session with check_confirmation and id params and confirmed account' do
    email = 'fourcade.m@gmail.com'
    employer = create(:employer, email:, confirmed_at: nil)
    employer.confirm
    get new_user_session_path(params: { check_confirmation: true, id: employer.id })
    assert_response :success
    assert_select('h1', text: 'Connexion à 1élève1stage')
  end

  test 'GET with prefilled email works' do
    email = 'fourcade.m@gmail.com'
    get new_user_session_path(email:)
    assert_response :success
    assert_select '#user_email[autofocus=autofocus]', count: 0
    assert_select "#user_email[value=\"#{email}\"]"
    assert_select '#user_password[autofocus=autofocus]'
  end

  test 'POST session not confirmed render warning with icon' do
    pwd = 'okokok1Max!!'
    student = create(:student, password: pwd, confirmed_at: nil)
    post user_session_path(params: { user: { channel: 'email',
                                             email: student.email,
                                             password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select '#alert-warning #alert-text',
                  text: 'Un message d’activation vous a été envoyé par courrier électronique. Veuillez suivre les instructions qu’il contient.', count: 1
  end

  test 'POST session with phone' do
    pwd = 'okokok1Max!!'
    phone = '+330637607756'
    student = create(:student, email: nil, phone:, password: pwd, confirmed_at: 2.days.ago)
    post user_session_path(params: { user: { channel: 'phone',
                                             phone: student.phone,
                                             password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select 'a[href=?]', account_path
  end

  test 'POST session with email' do
    pwd = 'okokok1Max!!'
    email = 'fourcade.m@gmail.com'
    student = create(:student, email:, phone: nil, password: pwd, confirmed_at: 2.days.ago)
    post user_session_path(params: { user: { channel: 'email',
                                             email: student.email,
                                             password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select 'a[href=?]', account_path
  end

  test 'POST session as EMPLOYER with email and check after sign in path when pending applications' do
    pwd = 'okokok1Max!!'
    email = 'employer@corp.com'
    employer = create(:employer, email:, phone: nil, password: pwd, confirmed_at: 2.days.ago)
    internship_offer = create(:weekly_internship_offer_2nde, employer:)
    create(:weekly_internship_application, :submitted, internship_offer:)

    post user_session_path(params: { user: { channel: 'email',
                                             email: employer.email,
                                             password: pwd } })

    assert_redirected_to dashboard_candidatures_path
  end

  test 'POST session as EMPLOYER with email and check after sign in path when no pending applications' do
    pwd = 'okokok1Max!!'
    email = 'employer@corp.com'
    employer = create(:employer, email:, phone: nil, password: pwd, confirmed_at: 2.days.ago)

    post user_session_path(params: { user: { channel: 'email',
                                             email: employer.email,
                                             password: pwd } })

    assert_redirected_to dashboard_internship_offers_path
  end

  test 'POST session as OPERATOR with email and check after sign in path when no pending applications' do
    pwd = 'okokok1Max!!'
    email = 'operator@corp.com'
    employer = create(:user_operator, email:, phone: nil, password: pwd, confirmed_at: 2.days.ago)

    post user_session_path(params: { user: { channel: 'email',
                                             email: employer.email,
                                             password: pwd } })

    assert_redirected_to dashboard_internship_offers_path
  end

  test 'GET #index as Student with a pending internship_application' do
    student = create(:student, password: 'okokok1Max!!')
    internship_offer = create(:weekly_internship_offer_3eme)
    internship_application = create(:weekly_internship_application, :validated_by_employer,
                                    student:,
                                    internship_offer:)

    post user_session_path(params: { user: { channel: 'email',
                                             email: student.email,
                                             password: 'okokok1Max!!' } })

    follow_redirect!
    assert_response :success
    assert response.body.include? 'Une de vos candidatures a été acceptée'
    assert_select 'a[href=?]',
                  dashboard_students_internship_application_path(student_id: student.id, uuid: internship_application.uuid), 1
  end

  test 'lock account' do
    right_password = 'polishThis1Holly!'
    wrong_password = 'piloshThis1Holly!'
    student = create(:student, password: 'okokok1Max!!', confirmed_at: nil)
    email = student.email

    post user_session_path(params: { user: { channel: 'email', email:, password: wrong_password } })
    assert_response :success
    assert_select 'p#text-input-error-desc-error-email', text: 'Adresse électronique  ou mot de passe incorrects',
                                                         count: 1
    # <p class="fr-error-text" id="text-input-error-desc-error-email">Adresse électronique  ou mot de passe incorrects</p>
    assert_equal 1, student.reload.failed_attempts
    max_attempts = Devise.maximum_attempts

    (max_attempts - 2).times do
      post user_session_path(params: { user: { channel: 'email', email:, password: wrong_password } })
    end
    assert_select('span#alert-text', text: 'Il vous reste une tentative avant que votre compte ne soit bloqué.',
                                     count: 1)
    assert_equal max_attempts - 1, student.reload.failed_attempts

    post user_session_path(params: { user: { channel: 'email', email:, password: wrong_password } })
    assert_equal max_attempts, student.reload.failed_attempts
    assert student.reload.access_locked?
  end

  test 'unlocking account sends an email' do
    student = create(:student)
    email = student.email

    student.lock_access!

    post user_unlock_path(params: { user: { email: } })
    assert_redirected_to new_user_session_path

    # using inside's Devise magics
    raw, enc = Devise.token_generator.generate(User, :unlock_token)
    student.update_columns(unlock_token: enc)
    # using inside's Devise magics end
    get user_unlock_path(unlock_token: raw)
    assert_redirected_to new_user_session_path
    refute student.reload.access_locked?
  end

  test 'session cookies are deleted on sign out' do
    student = create(:student)
    sign_in(student)
    delete destroy_user_session_path
    assert_nil cookies['_ms2gt_manage_session']
  end
end
