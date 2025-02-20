require 'test_helper'
class CallbacksControllerTest < ActionDispatch::IntegrationTest
  include ThirdPartyTestHelpers

  setup do
    @school = create(:school, code_uai: '0590121L')
    @student = create(:student,
                      ine: '1234567890',
                      confirmed_at: nil,
                      school: @school,
                      legal_representative_email: nil,
                      legal_representative_full_name: nil,
                      legal_representative_phone: nil)
    @code = '123456'
    @state = 'abc'
    @nonce = 'def'
    get root_path
    cookies[:state] = @state
  end

  test 'should get fim token and create SchoolManager user' do
    fim_token_stub
    fim_school_manager_userinfo_stub

    assert_difference 'User.count', 1 do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    assert_equal 'Users::SchoolManagement', User.last.type
    assert_equal 'school_manager', User.last.role
    assert_equal '0590121L', User.last.school.code_uai
  end
  test 'should get fim token and does not create user if school is not found' do
    fim_token_stub
    fim_teacher_without_school_userinfo_stub

    assert_no_difference 'User.count' do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
  end

  test 'should get fim token and create Teacher user' do
    fim_token_stub
    fim_teacher_userinfo_stub

    assert_difference 'User.count', 1 do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    assert_equal 'Users::SchoolManagement', User.last.type
    assert_equal 'teacher', User.last.role
    assert_equal '0590121L', User.last.school.code_uai
  end

  test 'should get fim token and create admin_officer role user' do
    fim_token_stub
    fim_admin_userinfo_stub

    assert_difference 'User.count', 1 do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    assert_equal 'Users::SchoolManagement', User.last.type
    assert_equal 'admin_officer', User.last.role
    assert_equal '0590121L', User.last.school.code_uai
  end

  test 'should get educonnect token and confirm student user' do
    educonnect_token_stub
    educonnect_userinfo_stub
    stub_omogen_auth
    stub_sygne_reponsible('1234567890')
    educonnect_logout_stub

    puts "school uai : #{@school.code_uai}"

    get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }

    @student.reload
    assert_response :redirect
    refute_nil @student.confirmed_at
    # assert_equal '07509232q', @student.school.code_uai # always change ?
    assert_equal 'I*************@email.co', @student.legal_representative_email
    assert_equal 'Mme Frederic CHIERICI', @student.legal_representative_full_name
    assert_equal '0506070809', @student.legal_representative_phone
  end

  test 'should get educonnect token and does not logged in user if student is unknown' do
    educonnect_token_stub
    educonnect_userinfo_unknown_stub
    educonnect_logout_stub

    get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }

    assert_response :redirect
    assert_nil @student.confirmed_at
  end
end
