# frozen_string_literal: true

require 'test_helper'

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test 'POST update with invalid token fails gracefully' do
    put user_password_path, params: {
      user: {
        password: '123456',
        reset_password_token: 'invalid'
      }
    }

    assert_select '.fr-alert.fr-alert--error'
    assert_select '.fr-alert.fr-alert--error',
                  count: 1,
                  text: 'Clé de réinitialisation du mot de passe : Veuillez faire une nouvelle demande de changement de mot de passe, cette demande a expiré.'
  end

  test 'POST update 2 times with valid token succeeds and then fails gracefully' do
    employer = create(:employer)
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    employer.update!(
      reset_password_token: hashed_token,
      reset_password_sent_at: Time.current
    )
    
    put user_password_path, params: {
      user: {
        password: 'Password123!',
        reset_password_token: raw_token
      }
    }

    # Check that there is no error
    assert_select '.fr-alert.fr-alert--error', count: 0
    assert_equal flash.notice, 'Votre mot de passe a bien été modifié. Vous êtes maintenant connecté(e).'

    # Logout
    delete destroy_user_session_path

    # Vérifier que l'utilisateur est bien déconnecté
    assert_response :redirect
    
  
    # 2nd time - using the same token (should fail)
    put user_password_path, params: {
      user: {
        password: 'Password123!',
        reset_password_token: raw_token
      }
    }
    
    
    assert_select '.fr-alert.fr-alert--error', count: 1
    assert_select '.fr-alert.fr-alert--error',
                  count: 1,
                  text: 'Clé de réinitialisation du mot de passe : Veuillez faire une nouvelle demande de changement de mot de passe, cette demande a expiré.'
  end

  test 'POST create by email' do
    student = create(:student)
    assert_enqueued_emails 1 do
      post user_password_path, params: { user: { channel: :email, email: student.email } }
      assert_redirected_to new_user_session_path
    end
  end

  test 'POST create by phone' do
    student = create(:student, email: nil, phone: '+330637607756')
    assert_enqueued_jobs 1, only: SendSmsJob do
      post user_password_path, params: { user: { channel: :phone, phone: student.phone } }
      assert_redirected_to phone_edit_password_path(phone: student.phone)
    end
  end

  test 'PUT update by phone' do
    new_password = 'newpassword1L!'
    student = create(:student, email: nil, phone: '+330637607756')
    refute student.nil?
    student.create_phone_token
    params = { phone: student.phone, phone_token: student.phone_token, password: new_password }
    put phone_update_password_path, params: params
    assert User.last.valid_password?(new_password)
  end
end
