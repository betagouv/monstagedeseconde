require 'test_helper'
class CallbacksControllerTest < ActionDispatch::IntegrationTest
  include ThirdPartyTestHelpers

  setup do
    @school = create(:school, code_uai: '0590121L')
    @student = create(:student, ine: '1234567890', confirmed_at: nil)
    @code = '123456'
    @state = 'abc'
    @nonce = 'def'
    get root_path
    cookies[:state] = @state
  end

  test 'should get fim token and create SchoolManager user' do
    fim_token_stub(@code)
    fim_school_manager_userinfo_stub

    get fim_callback_path, params: { code: @code, state: @state }

    assert_response :redirect
    assert_equal 1, User.count
    assert_equal 'Users::SchoolManagement', User.last.type
    assert_equal 'school_manager', User.last.role
    assert_equal '0590121L', User.last.school.code_uai
  end
  test 'should get fim token and does not create user if school is not found' do
    fim_token_stub(@code)
    fim_teacher_without_school_userinfo_stub

    get fim_callback_path, params: { code: @code, state: @state }

    assert_response :redirect
    assert_equal 0, User.count
  end

  test 'should get fim token and create Teacher user' do
    fim_token_stub(@code)
    fim_teacher_userinfo_stub

    get fim_callback_path, params: { code: @code, state: @state }

    assert_response :redirect
    assert_equal 1, User.count
    assert_equal 'Users::SchoolManagement', User.last.type
    assert_equal 'teacher', User.last.role
    assert_equal '0590121L', User.last.school.code_uai
  end

  test 'should get fim token and create admin_officer role user' do
    fim_token_stub(@code)
    fim_admin_userinfo_stub

    get fim_callback_path, params: { code: @code, state: @state }

    assert_response :redirect
    assert_equal 1, User.count
    assert_equal 'Users::SchoolManagement', User.last.type
    assert_equal 'admin_officer', User.last.role
    assert_equal '0590121L', User.last.school.code_uai
  end

  test 'should get educonnect token and confirm student user' do
    educonnect_token_stub
    educonnect_userinfo_stub

    get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }

    @student.reload
    assert_response :redirect
    refute_nil @student.confirmed_at
  end

  test 'should get educonnect token and does not logged in user if student is unknown' do
    educonnect_token_stub
    educonnect_userinfo_unknown_stub

    get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }

    assert_response :redirect
    assert_nil @student.confirmed_at
  end
end
