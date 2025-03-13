# frozen_string_literal: true

require 'application_system_test_case'

class SignInFlowTest < ApplicationSystemTestCase
  test 'not confirmed with email' do
    password = 'kikoolol'
    email = 'fourcade.m@gmail.com'
    user = create(:student, email: email,
                            password: password,
                            phone: nil,
                            confirmed_at: nil)

    visit new_user_session_path

    find('label', text: 'Email').click
    fill_in 'Adresse électronique', with: email
    fill_in 'Mot de passe', with: password
    click_on 'Connexion'
    error_message = find('#alert-text').text
    assert_equal 'Un message d’activation vous a été envoyé par courrier électronique. Veuillez suivre les instructions qu’il contient.',
                 error_message

    user.confirm
    visit new_user_session_path
    find('label', text: 'Email').click
    fill_in 'Adresse électronique', with: email
    fill_in 'Mot de passe', with: 'koko'
    click_on 'Connexion'
    error_message = find('#alert-text').text
    assert_equal 'Courriel, numéro de téléphone ou mot de passe incorrect.',
                 error_message

    fill_in 'Mot de passe', with: password

    click_on 'Connexion'
    find "a[href=\"#{account_path}\"]"
  end

  # test 'not confirmed with phone' do
  #   password = 'kikoolol'
  #   phone = '+330637607756'
  #   user = create(:student, email: nil,
  #                           phone: phone,
  #                           password: password,
  #                           confirmed_at: nil)

  #   # go to signup as employer
  #   visit new_user_session_path

  #   # fails to create employer with existing email
  #   find('label', text: 'SMS').click
  #   execute_script("document.getElementById('phone-input').value = '#{phone}';")

  #   fill_in 'Mot de passe', with: password
  #   click_on 'Connexion'
  #   error_message = find('#alert-text').text
  #   assert_equal 'Un message d’activation vous a été envoyé par courrier électronique. Veuillez suivre les instructions qu’il contient.',
  #                error_message

  #   user.confirm
  #   visit new_user_session_path
  #   find('label', text: 'SMS').click
  #   execute_script("document.getElementById('phone-input').value = '#{phone}';")
  #   fill_in 'Mot de passe', with: 'koko'
  #   click_on 'Connexion'

  #   error_message = find('#alert-text').text
  #   assert_equal 'Courriel, numéro de téléphone ou mot de passe incorrects.',
  #                error_message

  #   fill_in 'Mot de passe', with: password
  #   click_on 'Connexion'
  #   find "a[href=\"#{account_path}\"]"
  # end

  test 'inexistant account' do
    password = 'kikoololT4!,aA'
    phone = '+330637607756'

    visit new_user_session_path(as: 'Employer')
    # find('label', text: 'Email').click
    # find('label', text: 'Email').click
    fill_in 'Adresse électronique', with: 'email@free.fr'
    fill_in 'Mot de passe', with: password
    click_on 'Se connecter'
    assert_text 'Adresse électronique ou mot de passe incorrects'

    # phone connexion is not used anymore
    #  find('label', text: 'Téléphone').click
    # execute_script("document.getElementById('phone-input').value = '#{phone}';")
    # fill_in 'Numéro de mobile', with: phone
    # fill_in 'Mot de passe', with: password
    # click_on 'Connexion'
    # error_message = find('#alert-text').text
    # assert_equal 'Courriel, numéro de téléphone ou mot de passe incorrects.',
    #              error_message
  end

  test 'POST session with unconfirmed account data does not redirect to user' do
    # email = 'fourcade.m@gmail.com'
    pwd = 'okafdaokok1Max!!'
    student = create(:student, confirmed_at: nil, password: pwd)
    visit new_user_session_path(as: 'Employer')
    # find('label', text: 'Email').click
    fill_in 'Adresse électronique', with: student.email
    fill_in 'Mot de passe', with: pwd
    click_on 'Se connecter'
    assert_text 'Adresse électronique ou mot de passe incorrects'
    activation_text = 'Un message d’activation vous a été envoyé par courrier ' \
                      'électronique. Veuillez suivre les instructions qu’il contient.'
    find 'span#alert-text', text: activation_text
  end
end
