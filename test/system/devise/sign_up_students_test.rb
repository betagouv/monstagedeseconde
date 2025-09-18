# frozen_string_literal: true

require 'application_system_test_case'

class SignUpStudentsTest < ApplicationSystemTestCase
  # unfortunatelly on CI tests fails
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  def safe_submit
    click_on 'Valider'
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError
    execute_script("document.getElementById('new_user').submit()")
  end

end
