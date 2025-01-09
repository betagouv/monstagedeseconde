require 'test_helper'
class CallbacksControllerTest < ActionDispatch::IntegrationTest
  include ThirdPartyTestHelpers

  setup do
    @school = create(:school, code_uai: '0590121L')
    @code = '123456'
    @state = 'abc'
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
end
