# frozen_string_literal: true

require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET new redirects if no type is chosen' do
    get new_user_registration_path
    assert_redirected_to users_choose_profile_path
  end

  test 'POST #registrations as statistician whitelisted' do
    data = {
      first_name: 'James',
      last_name: 'Ref',
      email: 'test@free.fr',
      password: 'password1Maxx!!',
      department: '75',
      type: 'Users::PrefectureStatistician',
      accept_terms: true
    }

    post user_registration_path(user: data)

    assert_redirected_to statistician_standby_path(id: Users::PrefectureStatistician.last.id)
  end

  test 'POST #registrations as ministry statistician whitelisted' do
    data = {
      first_name: 'James',
      last_name: 'Ref',
      email: 'test@free.fr',
      password: 'password1MAx!!',
      type: 'Users::MinistryStatistician',
      accept_terms: true
    }

    post user_registration_path(user: data)

    assert_redirected_to statistician_standby_path(id: Users::MinistryStatistician.last.id)
  end

  test 'POST #registrations as education statistician whitelisted' do
    data = {
      first_name: 'James',
      last_name: 'Ref',
      email: 'test@free.fr',
      department: '75',
      password: 'password1Maxx!',
      type: 'Users::EducationStatistician',
      accept_terms: true
    }

    post user_registration_path(user: data)

    assert_redirected_to statistician_standby_path(id: Users::EducationStatistician.last.id)
  end

  test 'GET #choose_profile' do
    get users_choose_profile_path
    assert_select 'title', 'Création de compte | 1Elève1Stage'
    # assert_select 'a[href=?]', '/identites/nouveau?as=Student'
    assert_select 'a[href=?]', '/utilisateurs/inscription?as=Employer'
    # assert_select 'a[href=?]', '/utilisateurs/inscription?as=SchoolManagement'
    # assert_select 'a[href=?]', '/utilisateurs/inscription?as=Statistician'
  end

  test 'GET #registrations_standby as student using path?id=#id with pending account' do
    email = 'fourcade.m@gmail.com'
    student = create(:student, email:, confirmed_at: nil)
    get users_registrations_standby_path(id: student.id)
    assert_response :success
    assert_select('p.h3', text: 'Confirmez votre compte')
  end

  test 'GET #registrations_standby as employer using path?id=#id with pending account' do
    email = 'fourcade.m@gmail.com'
    employer = create(:employer, email:, confirmed_at: nil)
    get users_registrations_standby_path(id: employer.id)
    assert_response :success
    assert_select('p.h3', text: 'Confirmez votre compte')
  end

  test 'GET #registrations_standby using path?id=#id with confirmed account' do
    email = 'fourcade.m@gmail.com'
    student = create(:student, email:, confirmed_at: Time.now)
    get users_registrations_standby_path(id: student.id)
    assert_response :success
    assert_select '.fr-alert.fr-alert--success',
                  text: 'Votre compte est déjà confirmé (fo********@gmail.com)Veuillez vous connecter'
  end

  # What use case ??
  test 'GET #registrations_standby using path?id=#id with unknown account' do
    random_id = 132
    get users_registrations_standby_path(id: random_id)
    assert_response :success
    assert_select '.fr-alert.fr-alert--error',
                  text: "Aucun compte n'est lié à cet identifiant : #{random_id}Veuillez créer un compte"
  end
end
