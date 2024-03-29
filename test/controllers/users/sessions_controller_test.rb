# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'GET works' do
    get new_user_session_path
    assert_response :success
    assert_select 'title', "Connexion | Stages de 2de"
    assert_select '#user_email'
    assert_select '#select-channel-phone'
    assert_select '#user_password[autofocus=autofocus]', count: 0
  end

  test 'GET #new_session with check_confirmation and id params and unconfirmed account' do
    email = 'fourcade.m@gmail.com'
    employer = create(:employer, email: email, confirmed_at: nil)
    get new_user_session_path(params:{check_confirmation: true, id: employer.id})
    follow_redirect!
    assert_response :success
    assert_select('.h2', text: '1 . Activez votre compte !')
    flash_message = 'Vous trouverez parmi vos emails le message' \
                      ' permettant l\'activation de votre compte'
    assert_select('span#alert-text', text: flash_message) # 1
  end

  test 'GET #new_session with check_confirmation and id params and confirmed account' do
    email = 'fourcade.m@gmail.com'
    employer = create(:employer, email: email, confirmed_at: nil)
    employer.confirm
    get new_user_session_path(params:{check_confirmation: true, id: employer.id})
    assert_response :success
    assert_select('h1', text: 'Connexion à Mon stage de seconde')
  end

  test 'GET with prefilled email works' do
    email = 'fourcade.m@gmail.com'
    get new_user_session_path(email: email)
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
    assert_select '#alert-warning #alert-text', text: 'Un message d’activation vous a été envoyé par courrier électronique. Veuillez suivre les instructions qu’il contient.', count: 1
  end

  test 'POST session with phone' do
    pwd = 'okokok1Max!!'
    phone = '+330637607756'
    student = create(:student, email: nil, phone: phone, password: pwd, confirmed_at: 2.days.ago)
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
    student = create(:student, email: email, phone: nil, password: pwd, confirmed_at: 2.days.ago)
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
    employer = create(:employer, email: email, phone: nil, password: pwd, confirmed_at: 2.days.ago)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    create(:weekly_internship_application, :submitted, internship_offer: internship_offer)

    post user_session_path(params: { user: { channel: 'email',
                                             email: employer.email,
                                             password: pwd } })
    
    assert_redirected_to dashboard_candidatures_path
  end

  test 'POST session as EMPLOYER with email and check after sign in path when no pending applications' do
    pwd = 'okokok1Max!!'
    email = 'employer@corp.com'
    employer = create(:employer, email: email, phone: nil, password: pwd, confirmed_at: 2.days.ago)

    post user_session_path(params: { user: { channel: 'email',
                                             email: employer.email,
                                             password: pwd } })
    
    assert_redirected_to dashboard_internship_offers_path
  end

  test 'GET #index as Student with a pending internship_application' do
      student = create(:student, password: 'okokok1Max!!')
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:weekly_internship_application, :validated_by_employer,
            student: student,
            internship_offer: internship_offer)

      post user_session_path(params: { user: { channel: 'email',
                                               email: student.email,
                                               password: 'okokok1Max!!' } })
      
                                               follow_redirect!
      assert_response :success
      assert response.body.include? 'Une de vos candidatures a été acceptée'
      assert_select 'a[href=?]', dashboard_students_internship_application_path(student_id: student.id, id: internship_application.id), 1
    end
end
