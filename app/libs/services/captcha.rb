module Services
  # Manage Captcha services
  class Captcha
    def self.generate
      token = get_oauth_token
      uri = URI(ENV["CAPTCHA_URL"] + '/simple-captcha-endpoint?get=image&c=captchaFR')
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      
      request = Net::HTTP::Get.new(uri.request_uri)
      request["Authorization"] = "Bearer #{token}"
      
      response = http.request(request)
      
      case response
      when Net::HTTPSuccess
        [JSON.parse(response.body)["imageb64"], JSON.parse(response.body)["uuid"]]
      else
        raise "Failed to get captcha image: #{response.message}"
      end
    end

    def self.verify(captcha, uuid)
      token = get_oauth_token
      uri = URI(ENV["CAPTCHA_URL"] + '/valider-captcha')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Post.new(uri.request_uri)
      # add params to the request captch and uuid
      request.set_form_data(code: captcha, uuid: uuid)
      response = http.request(request)
      puts response.body
    end

    def self.get_oauth_token
      uri = URI(ENV["PISTE_OAUTH_URL"])
      response = Net::HTTP.post_form(uri, {
        grant_type: "client_credentials",
        client_id: ENV["CAPTCHA_CLIENT_ID"],
        client_secret: ENV["CAPTCHA_CLIENT_SECRET"],
        scope: "piste.captchetat"
      })
      JSON.parse(response.body)["access_token"]
    end
  end
end
