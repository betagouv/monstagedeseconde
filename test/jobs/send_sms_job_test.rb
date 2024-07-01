# frozen_string_literal: true

require 'test_helper'
class SendSmsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

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
      stub_request(:get, "https://europe.ipx.com/restapi/v1/sms/send?campaignName=&destinationAddress=#{computed_phone_number}&messageText=Hello%20World&originatingAddress=MonStage2de&originatorTON=1&password=#{ENV['LINK_MOBILITY_SECRET']}&username=#{ENV['LINK_MOBILITY_USER']}").
          with(
            headers: {
                  'Accept'=>'application/json',
                  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Host'=>'europe.ipx.com',
                  'User-Agent'=>'Ruby'
            }).to_return(status: 200, body: {body: 'ok', responseCode: 0}.to_json, headers: {})
      assert_equal true, SendSmsJob.perform_now(user: user, message: message)
    end
  end

  test 'perform with a dom_tom user' do
    message = 'Hello World'
    computed_phone_number = '2620601020304'
    phone_number = '+2620601020304'
    user = create(:user, phone: phone_number)
    # parameters = {phone_number: user.phone, content: message}
    Services::SmsSender.stub_any_instance(:perform, 'ok') do
      assert_equal 'ok', SendSmsJob.perform_now(user: user, message: message)
    end
    Services::SmsSender.new(phone_number: user.phone, content: message).stub(:perform, 'ok') do
      
      stub_request(:get, "https://europe.ipx.com/restapi/v1/sms/send?campaignName=&destinationAddress=#{computed_phone_number}&messageText=Hello%20World&originatingAddress=MonStage2de&originatorTON=1&password=#{ENV['LINK_MOBILITY_SECRET']}&username=#{ENV['LINK_MOBILITY_USER']}").
          with(
            headers: {
                  'Accept'=>'application/json',
                  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Host'=>'europe.ipx.com',
                  'User-Agent'=>'Ruby'
            }).to_return(status: 200, body: {body: 'ok', responseCode: 0}.to_json, headers: {})
      assert_equal true, SendSmsJob.perform_now(user: user, message: message)
    end
  end
end