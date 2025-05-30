module Services
  class SmsSender
    include ApiRequestsHelper
    LINK_MOBILITY_SENDING_ENDPOINT_URL = 'https://europe.ipx.com/restapi/v1/sms/send'.freeze

    def perform
      if no_sms_mode?
        treat_no_sms_message
      else
        uri = URI("#{LINK_MOBILITY_SENDING_ENDPOINT_URL}?#{making_body.to_query}")
        response = get_request(uri, default_headers)
        if response.nil? || !response.respond_to?(:body)
          error_message = 'Link Mobility error: response is ko | phone_number: ' \
                          "#{@phone_number} | content: #{@content}"
          Rails.logger.error(error_message)
          return nil
        end
        response_body = JSON.parse(response.body)
        status?(0, response_body) ? log_success(response_body) : log_failure(response_body)
      end
    end

    attr_reader :phone_number, :content, :sender_name, :user, :pass, :campaign_name

    private

    def no_sms_mode?
      ENV.fetch('NO_SMS', false) == 'true'
    end

    def treat_no_sms_message
      info = "===> No SMS mode activated | phone_number: #{@phone_number} | content: #{@content}"
      Rails.logger.info(info)
      puts '----------------------------------'
      puts info
      puts '----------------------------------'
      true
    end

    def log_success(response_body)
      info = "Link Mobility success for phone '#{@phone_number}', with content " \
            "'#{@content}' | traceId: '#{response_body['traceId']}' | " \
            "messageIds: '#{response_body['messageIds']}'"
      Rails.logger.info(info)
      true
    end

    def log_failure(response_body)
      error_message = "Link Mobility error: '#{response_body['responseMessage']}', " \
                      "with code #{response_body['responseCode']}, for phone" \
                      " '#{@phone_number}', with content '#{@content}'"
      Rails.logger.error(error_message)
      false
    end

    def making_body
      # maxConcatenatedMessages is 3 by default
      {
        destinationAddress: phone_number,
        messageText: content,
        username: user,
        password: pass,
        originatingAddress: sender_name,
        campaignName: campaign_name,
        originatorTON: 1 # 1 = Alphanumeric, 2 = Shortcode, 3 = MSISDN
      }
    end

    #   # expected: Int|Array[Int],
    #   # response: HttpResponse
    def status?(expected, response_body)
      actual = response_body['responseCode']&.to_i
      Array(expected).include?(actual)
    end

    def default_headers
      { 'Accept': 'application/json' }
    end

    def initialize(phone_number:, content:, campaign_name: nil)
      @phone_number = phone_number
      @campaign_name = campaign_name
      @content = content
      @sender_name = '1E1S' # Max length: 11 chars
      @user = ENV['LINK_MOBILITY_USER']
      @pass = ENV['LINK_MOBILITY_SECRET']
    end
  end
end
