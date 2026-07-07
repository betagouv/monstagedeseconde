# frozen_string_literal: true

require 'application_system_test_case'

class SignUpMinistryStatisticiansTest < ApplicationSystemTestCase
  include ThirdPartyTestHelpers
  test 'navigation & interaction works until ministry statistician creation' do
    captcha_stub do
      # create ministry_statistician with previously set email
      create(:public_group, name: 'Ministère de la Justice')
      create(:public_group, name: "Ministère de l'intérieur")
      visit new_user_registration_path(as: 'Statistician')
      email = 'kikoolol@gmail.com'
      assert Group.is_public.count > 1
      assert_difference('Users::MinistryStatistician.count', 1) do
        fill_in 'Prénom', with: 'Martin'
        find("input[name='user[last_name]']").fill_in(with: 'Fourcade')
        # le choix du type déclenche le stimulus signup (action du formulaire + champs)
        choose('user_statistician_ministry_type', allow_label_click: true)
        select('Ministère de la Justice', from: 'Choisissez le ministère correspondant')
        fill_in 'Adresse électronique', with: email
        execute_script("document.getElementById('user_accept_terms').checked = true;")
        find('#user_captcha').set('ABC123')
        # le bouton Valider n'est activé que par la saisie d'un mot de passe valide
        fill_in 'Créer un mot de passe', with: 'kikoololletest1Max!!'
        click_on 'Valider'
      end

      # check created statistician has valid info
      created_ministry_statistician = Users::MinistryStatistician.where(email:).last
      assert_equal 'Martin', created_ministry_statistician.first_name
      assert_equal 'Fourcade', created_ministry_statistician.last_name
    end
  end
end
