# frozen_string_literal: true

require 'test_helper'

class HolidaysMaintenanceTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    Flipper.enable(:holidays_maintenance)
  end

  teardown do
    Flipper.disable(:holidays_maintenance)
  end

  test 'visitor is redirected to maintenance page' do
    get root_path
    assert_redirected_to '/maintenance_estivale.html'
  end

  test 'sign in page stays reachable' do
    get new_user_session_path
    assert_response :success
    assert_select '#user_email'
  end

  test 'magic link path stays reachable' do
    get magic_link_path(token: 'invalid')
    assert_redirected_to new_user_session_path
  end

  test 'two factor challenge path stays reachable' do
    get two_factor_challenge_path
    assert_redirected_to new_user_session_path
  end

  test 'POST sessions with non god credentials is rejected without signing in' do
    employer = create(:employer, password: 'Password123!', password_confirmation: 'Password123!')

    post user_session_path, params: {
      user: { email: employer.email, password: 'Password123!' }
    }

    assert_redirected_to '/maintenance_estivale.html'
    assert_not is_logged_in?
  end

  test 'POST sessions with god credentials goes through' do
    admin = create(:god, password: 'Password123!', password_confirmation: 'Password123!')

    post user_session_path, params: {
      user: { email: admin.email, password: 'Password123!' }
    }

    assert is_logged_in?
  end

  test 'POST sessions with god email in mixed case and padded goes through' do
    admin = create(:god, password: 'Password123!', password_confirmation: 'Password123!')

    post user_session_path, params: {
      user: { email: " #{admin.email.upcase} ", password: 'Password123!' }
    }

    assert is_logged_in?
  end

  test 'signed in god is not redirected to maintenance page' do
    admin = create(:god)
    sign_in admin

    get root_path
    assert_response :success
  end

  test 'signed in non god user is still redirected to maintenance page' do
    employer = create(:employer)
    sign_in employer

    get root_path
    assert_redirected_to '/maintenance_estivale.html'
  end

  test 'visitor is not redirected when flag is off' do
    Flipper.disable(:holidays_maintenance)

    get root_path
    assert_response :success
  end

  private

  def is_logged_in?
    !session['warden.user.user.key'].blank?
  end
end
