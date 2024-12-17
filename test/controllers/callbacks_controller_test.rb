require 'test_helper'
class CallbacksControllerTest < ActionDispatch::IntegrationTest
  include ThirdPartyTestHelpers

  test 'should get fim' do
    code = '123456'
    state = 'abc'

    get root_path
    cookies[:state] = state

    fim_token_stub do
      get fim_callback_path, params: { code: code, state: state }
    end

    assert_response :success
    # assert_equal 'Vous êtes bien connecté', flash[:notice]
    # assert_equal 1, User.count
    # assert_equal 'Users::SchoolManagement', User.last.type
    # assert_equal 'admin', User.last.role
    # assert_equal '0590121L', User.last.school_id
  end
end
