require 'json'

module Services
  class EduconnectConnection
    def initialize(code, state)
      @code = code
      @state = state
      @token = get_token
    end

    def get_user_info
      headers = {
        'Authorization' => "Bearer #{@token}",
        'Content-Type' => 'application/json'
      }

      url = "#{ENV.fetch('EDUCONNECT_URL')}/idp/profile/oidc/userinfo"
      uri = URI(url)

      # Créer une requête HTTP complète
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri)
      headers.each { |key, value| request[key] = value }

      response = http.request(request)
      puts "Response: #{response}"
      puts "Response body: #{response.body}"

      raise "Failed to get user info: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    private

    def get_token
      body = {
        client_id: ENV.fetch('EDUCONNECT_CLIENT_ID'),
        client_secret: ENV.fetch('EDUCONNECT_CLIENT_SECRET'),
        code: @code,
        grant_type: 'authorization_code',
        redirect_uri: ENV.fetch('EDUCONNECT_REDIRECT_URI'),
        scope: 'openid stage profile email', # Ordre corrigé des scopes
        state: @state,
        nonce: SecureRandom.uuid
      }

      url = "#{ENV.fetch('EDUCONNECT_URL')}/idp/profile/oidc/token"
      uri = URI(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.body = URI.encode_www_form(body)

      puts "Request body: #{request.body}" # Pour debug
      response = http.request(request)
      puts "Response: #{response.body}"

      raise "Failed to get token: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)['access_token']
    end
  end
end
