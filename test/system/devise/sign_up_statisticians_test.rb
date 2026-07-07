# frozen_string_literal: true

require 'application_system_test_case'

class SignUpStatisticiansTest < ApplicationSystemTestCase
  include ThirdPartyTestHelpers
  test 'navigation & interaction works until statistician creation' do
    captcha_stub do
      # go to signup as statistician
      bad_email = 'lol@lol.fr'
      good_email = 'kikoolol@gmail.com'
      valid_password = 'kikoololletest1Max!!'

      visit new_user_registration_path(as: 'Statistician')

      assert_difference('Users::EducationStatistician.count', 1) do
        fill_in 'Prénom', with: 'Martin'
        fill_in 'Nom', with: 'Fourcade'
        # le choix du type déclenche le stimulus signup (action du formulaire + champs)
        choose('user_statistician_education', allow_label_click: true)
        select('75 - Paris', from: 'user_department')
        fill_in 'Adresse électronique', with: good_email
        fill_in 'Créer un mot de passe', with: valid_password
        execute_script("document.getElementById('user_accept_terms').checked = true;")
        find('#user_captcha').set('ABC123')
        click_on 'Valider'
      end

      # check created statistician has valid info
      created_statistician = Users::EducationStatistician.find_by(email: good_email)
      assert_equal 'Martin', created_statistician.first_name
      assert_equal 'Fourcade', created_statistician.last_name
      # les statisticiens sont désormais signataires par défaut (colonne default true)
      assert_equal true, created_statistician.agreement_signatorable
    end
  end
end
