require 'json'

module Services
  class FimConnection
    def initialize(code, state)
      @code = code
      @state = state
      @token = get_token
    end

    # {
    #   "FrEduFonctAdm": "DIR",
    #   "sub": "abcdef",
    #   "FrEduRne": [
    #     "0590121L$UAJ$PU$DIR$0590121L$T3$LYC$3000",
    #     "0590258K$UAJ$PU$DIR$0590258K$T3$LYC$3000"
    #   ],
    #   "rne": "0590121l",
    #   "FrEduRneResp": [
    #     "0590258K",
    #     "0590121L"
    #   ],
    #   "title": "DIR",
    #   "given_name": "Julien",
    #   "typensi": "G",
    #   "codaca": "009",
    #   "family_name": "Champ",
    #   "email": "julien.champ@ac-lille.fr"
    # }
    def get_user_info
      headers = {
        'Authorization' => "Bearer #{@token}",
        'Content-Type' => 'application/json'
      }

      url = "#{ENV.fetch('FIM_URL')}/api/v1/users/me"

      response = Net::HTTP.get(URI("#{ENV.fetch('FIM_URL')}"), headers)

      raise "Failed to get user info: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    private

    def get_token
      body = {
        client_id: ENV.fetch('FIM_CLIENT_ID'),
        client_secret: ENV.fetch('FIM_CLIENT_SECRET'),
        code: @code,
        grant_type: 'authorization_code',
        redirect_uri: ENV.fetch('FIM_REDIRECT_URI'),
        scope: 'openid stage profile email', # Ordre corrigé des scopes
        state: @state,
        nonce: SecureRandom.uuid
      }

      url = "#{ENV.fetch('FIM_URL')}/idp/profile/oidc/token"
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
