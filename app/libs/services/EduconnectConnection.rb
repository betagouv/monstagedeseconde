require 'json'

module Services
  class EduconnectConnection
    def initialize(code, state, nonce)
      @code = code
      @state = state
      @nonce = nonce
      @token = get_token
    end

    def get_user_info
      response = make_request(
        :get,
        "#{ENV.fetch('EDUCONNECT_URL')}/idp/profile/oidc/userinfo",
        headers: auth_headers
      )

      return {} if response.body.blank?

      JSON.parse(response.body)
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse Educonnect response: #{e.message}")
      Rails.logger.error("Response body: #{response&.body.inspect}")
      {}
    end

    def self.logout(id_token)
      make_request(
        :get,
        "#{ENV.fetch('EDUCONNECT_URL')}/idp/profile/oidc/logout",
        headers: { 'Authorization' => "Bearer #{id_token}" }
      )
    end

    private

    def get_token
      body = {
        client_id: ENV.fetch('EDUCONNECT_CLIENT_ID'),
        client_secret: ENV.fetch('EDUCONNECT_CLIENT_SECRET'),
        code: @code,
        grant_type: 'authorization_code',
        redirect_uri: ENV.fetch('EDUCONNECT_REDIRECT_URI'),
        state: @state,
        nonce: @nonce
      }

      response = make_request(
        :post,
        "#{ENV.fetch('EDUCONNECT_URL')}/idp/profile/oidc/token",
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        body: URI.encode_www_form(body)
      )

      session[:id_token] = JSON.parse(response.body)['id_token']

      JSON.parse(response.body)['access_token']
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse Educonnect response: #{e.message}")
      Rails.logger.error("Response body: #{response&.body.inspect}")
      nil
    end

    def make_request(method, url, headers: {}, body: nil)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      request = "Net::HTTP::#{method.to_s.capitalize}".constantize.new(uri)
      headers.each { |key, value| request[key] = value }
      request.body = body if body

      Rails.logger.info("Making #{method.upcase} request to #{url}")
      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("Educonnect request failed: Status: #{response.code}, Body: #{response.body.inspect}")
        return OpenStruct.new(body: '')
      end

      response
    end

    def auth_headers
      {
        'Authorization' => "Bearer #{@token}",
        'Content-Type' => 'application/json'
      }
    end
  end
end
