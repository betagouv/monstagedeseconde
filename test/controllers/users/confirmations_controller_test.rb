# frozen_string_literal: true

require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET confirmation by email with with valid token and not confirmed user' do
    employer = create(:employer)
    employer.confirmed_at = nil
    employer.confirmation_token = 'abc'
    employer.save

    get user_confirmation_path(confirmation_token: employer.confirmation_token)
    assert_redirected_to new_user_session_path(email: employer.email)
    follow_redirect!
    assert_select('#alert-success #alert-text', text: 'Votre compte est bien confirmé. Vous pouvez vous connecter.')
  end

  test 'GET#new_user_confirmation' do
    employer = create(:employer, confirmed_at: nil)
    get new_user_confirmation_path
    assert_response :success
    assert_select 'title', 'Confirmation | 1Élève1Stage'
  end

  test 'CREATE#user_confirmation by email' do
    student = create(:employer, phone: nil,
                                email: 'fourcade.m@gmail.com',
                                confirmed_at: nil)
    assert_enqueued_emails 1 do
      post user_confirmation_path(user: { channel: :email, email: student.email })
    end
    assert_redirected_to new_user_session_path
  end
end
