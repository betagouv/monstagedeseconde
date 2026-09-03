# frozen_string_literal: true

require 'test_helper'

class ChatmdTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    ENV['CHATMD_MARKDOWN_URL'] = 'https://example.com/chatbot.md'
    Flipper.enable(:chatmd)
  end

  teardown do
    ENV.delete('CHATMD_MARKDOWN_URL')
    Flipper.disable(:chatmd)
  end

  test 'chatmd bubble is shown on the student login page for a visitor' do
    get student_login_path

    assert_select '.chatmd-widget', count: 1
    assert_select '.chatmd-widget iframe[data-src=?]',
                  'https://chatmd.forge.apps.education.fr/#https://example.com/chatbot.md'
  end

  test 'chatmd bubble is hidden on other pages for a visitor' do
    [ root_path, pro_login_path, school_management_login_path ].each do |path|
      get path

      assert_select '.chatmd-widget', { count: 0 },
                    "expected the chatmd bubble to be hidden on #{path}"
    end
  end

  test 'chatmd bubble is shown once signed in' do
    sign_in create(:employer)
    get root_path

    assert_select '.chatmd-widget', count: 1
  end

  test 'chatmd bubble is hidden when no markdown url is configured' do
    ENV.delete('CHATMD_MARKDOWN_URL')
    get student_login_path

    assert_select '.chatmd-widget', count: 0
  end

  test 'chatmd bubble is hidden when the chatmd feature is disabled' do
    Flipper.disable(:chatmd)
    get student_login_path

    assert_select '.chatmd-widget', count: 0
  end
end
