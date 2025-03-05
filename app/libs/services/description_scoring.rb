module Services
  class DescriptionScoring < ApiRequestsHelper
    SCORE_API_URL = "#{ENV['SCORE_API_URL']}".freeze

    def perform
      response = post_request(body: body)
      if response.nil? || !response.respond_to?(:body)
        error_message = 'Faulty request : consider contacting developper'
        Rails.logger.error(error_message)
      end
      if response && response.respond_to?(:code) && status?(200, response)
        score_response = JSON.parse(response.body)
        # score is between -1 and 1
        ((score_response['score'] + 1) * 10) # mark between 0 and 20
      else
        log_failure(response)
        -1
      end
    end

    private

    def log_failure(response)
      error_message = "Error #{response.try(:code)} with message: " \
                      "#{response} for description-scoring "
      Rails.logger.error(error_message)
    end

    def post_request_uri
      URI("#{SCORE_API_URL}/score")
    end

    def body
      {
        employer_name:, title:, id:, aasm_state:, discarded_at:,
        description:, index:, norma:, "sectors- sector_id → name": sector_name
      }
    end

    def get_token
      body = {
        username: ENV.fetch('SCORE_API_USER'),
        password: ENV.fetch('SCORE_API_PASSWORD')
      }

      url = "#{SCORE_API_URL}/login"
      uri = URI(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = body.to_json

      response = http.request(request)

      raise "Failed to get token: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)['access_token']
    end

    def default_headers
      # 'Content-Type': 'application/x-www-form-urlencoded',
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{get_token}"
      }
    end

    attr_reader :employer_name, :title, :id, :aasm_state, :discarded_at, :description, :index, :norma, :sector_name

    private

    def initialize(instance:)
      @employer_name = '' # internship_offer.employer_name
      @title = instance.title
      @sector_name = '' # internship_offer.sector.name
      @id = 0
      @aasm_state = instance.try(:aasm_state) || ''
      @discarded_at = instance.try(:discarded_at)
      @description = instance.description
      @index = 10_000
      @norma = sanitize(instance.description)
    end

    def sanitize(description)
      description.strip.gsub(/-/, ' ')
    end
  end
end
