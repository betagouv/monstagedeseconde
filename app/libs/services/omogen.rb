module Services
  # Manage Captcha services
  class Omogen
    def net_synchro
      uri = URI(ENV['NET_SYNCHRO_URL'])

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = "Bearer #{@token}"
      request['Code-Application'] = 'FRE'
      request['Code-RNE'] = '0595121W'
      request['Compression-Zip'] = 'non'
      request['Contexte-Annee-Scolaire'] = '2021'
      request['Perimetre-Applicatif'] = 'A09'

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "Failed to get netsynchro resource : #{response.message}"
      end
    end

    def sygne
      uri = URI(ENV['SYGNE_URL'])

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = "Bearer #{@token}"
      request['Code-Application'] = 'FRE'
      request['Code-RNE'] = '0595121W'
      request['Compression-Zip'] = 'non'
    end

    def sygne_status
      uri = URI(ENV['SYGNE_URL'] + '/version')
      puts uri

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = "Bearer #{@token}"

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        puts response.body
        JSON.parse(response.body)
      else
        puts response
        puts response.body
        puts response.code
        puts response.message

        raise "Failed to get sygne status : #{response.message}"
      end
    end

    def sygne_eleves
      uri = URI(ENV['SYGNE_URL'] + '/etablissements/0590116F/eleves')
      puts uri

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = "Bearer #{@token}"
      request['Compression-Zip'] = 'non'

      puts 'request', request
      puts 'uri', uri
      puts '----'

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        puts response.body
        JSON.parse(response.body)
      else
        puts response
        puts response.body
        raise "Failed to get sygne eleves : #{response.message}"
      end
    end

    def get_oauth_token
      uri = URI(ENV['OMOGEN_OAUTH_URL'])
      response = Net::HTTP.post_form(uri, {
                                       grant_type: 'client_credentials',
                                       client_id: ENV['OMOGEN_CLIENT_ID'],
                                       client_secret: ENV['OMOGEN_CLIENT_SECRET']
                                     })
      JSON.parse(response.body)['access_token']
    end

    def initialize
      @token = get_oauth_token
    end
  end
end
