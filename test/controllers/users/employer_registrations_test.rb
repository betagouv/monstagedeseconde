# frozen_string_literal: true

require 'test_helper'

class EmployerRegistrationsTest < ActionDispatch::IntegrationTest
  include ThirdPartyTestHelpers

  def assert_employer_form_rendered
    assert_select 'title', 'Inscription | 1Elève1Stage'
    assert_select 'input', value: 'Employer', hidden: 'hidden'
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /J'accepte les/
  end

  test 'GET new as a Employer' do
    captcha_stub do
      get new_user_registration_path(as: 'Employer')

      assert_response :success
      assert_employer_form_rendered
    end
  end

  test 'POST Create Employer' do
    assert_difference('Users::Employer.count') do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok1Max!!',
                                                    employer_role: 'chef de projet',
                                                    first_name: 'Madame',
                                                    last_name: 'Accor',
                                                    type: 'Users::Employer',
                                                    phone_prefix: '+33',
                                                    phone_suffix: '0612345678',
                                                    accept_terms: '1' } })
    end
    created_employer = Users::Employer.last
    assert_redirected_to users_registrations_standby_path(id: created_employer.id)
    assert created_employer.current_area.is_a?(InternshipOfferArea)
  end

  test 'post should not subscribe when confirmation is sent' do
    assert_no_difference('Users::Employer.count') do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    confirmation_email: 'madame@accor.fr',
                                                    password: 'okokok1Max!!',
                                                    employer_role: 'chef de projet',
                                                    first_name: 'Madame',
                                                    last_name: 'Accor',
                                                    type: 'Users::Employer',
                                                    phone_prefix: '+33',
                                                    phone_suffix: '0612345678',
                                                    accept_terms: '1' } })
    end
    assert_redirected_to root_path
    notice = 'Votre inscription a bien été prise en compte. ' \
             'Vous recevrez un email de confirmation dans ' \
             'les prochaines minutes.'
    assert_equal notice, flash[:notice]
  end
end
