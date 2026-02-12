# frozen_string_literal: true

require 'test_helper'
class SendSmsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  include ThirdPartyTestHelpers

  test 'perform' do
    message = 'Hello World'
    phone_number = '+330601020304'
    user = create(:user, phone: phone_number)
    # parameters = {phone_number: user.phone, content: message}
    Services::SmsSender.stub_any_instance(:perform, 'ok') do
      assert_equal 'ok', SendSmsJob.perform_now(user: user, message: message)
    end
    Services::SmsSender.new(phone_number: user.phone, content: message).stub(:perform, 'ok') do
      computed_phone_number = '33601020304'
      stub_sms(computed_phone_number)
      assert_equal true, SendSmsJob.perform_now(user: user, message: message)
    end
  end

  test 'perform with a dom_tom user' do
    message = 'Hello World'
    computed_phone_number = '2620601020304'
    phone_number = '+2620601020304'
    user = create(:user, phone: phone_number)
    # parameters = {phone_number: user.phone, content: message}
    stub_sms(computed_phone_number)
    Services::SmsSender.stub_any_instance(:perform, 'ok') do
      assert_equal 'ok', SendSmsJob.perform_now(user: user, message: message)
    end
    Services::SmsSender.new(phone_number: user.phone, content: message).stub(:perform, 'ok') do
      assert SendSmsJob.perform_now(user: user, message: message)
    end
  end
end
