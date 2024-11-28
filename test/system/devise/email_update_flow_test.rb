# frozen_string_literal: true

require 'application_system_test_case'

class EmailUpdateFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  # include ::EmailSpamEuristicsAssertions

  test 'student updates her email' do
    skip "this test is relevant and shall be reactivated by november 2024"
    password  = 'kikoolol1Max!!'
    email     = 'fourcade.m@gmail.com'
    alt_email = 'another_email@free.fr'
    user = create(:student, email: email,
                            password: password,
                            phone: nil,
                            confirmed_at: Time.now.utc)
    sign_in(user)
    assert_changes -> { user.reload.unconfirmed_email } do
      visit account_path
      fill_in('Adresse électronique (ex : mon@domaine.fr)', with: alt_email)
      click_on('Enregistrer mon CV')
      success_message = find('#alert-text').text
      expected_message = "Compte mis à jour avec succès. Pour confirmer le changement " \
                         "d’adresse électronique, veuillez cliquer sur lien contenu " \
                         "dans le courrier que vous venez de recevoir sur votre " \
                         "nouvelle adresse électronique."
      assert_equal expected_message, success_message
    end
    visit account_path
    assert_equal alt_email, find('#user_unconfirmed_email').value
    assert_text(
      "Cet email n'est pas encore confirmé : veuillez consulter vos emails"
    )
    find_link( text: "Vous n'avez pas reçu le message d'activation ?" ).click
    find('label[for=select-channel-email]').click
    execute_script("document.getElementById('user_email').value = '#{alt_email}';")

    click_on('Renvoyer')
    user.confirm
    visit account_path
    assert_equal alt_email, find('#user_email_1').value
  end
end
