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
        response.body
      else
        puts response
        puts response.body
        puts response.code
        puts response.message

        raise "Failed to get sygne status : #{response.message}"
      end
    end

    # Sygne eleves
    #  {
    #  "ine"=>"001291528AA",
    #  "nom"=>"SABABADICHETTY",
    #  "prenom"=>"Felix",
    #  "dateNaissance"=>"2003-05-28",
    #  "codeSexe"=>"1",
    #  "codeUai"=>"0590116F",
    #  "anneeScolaire"=>2023,
    #  "niveau"=>"2212",
    #  "libelleNiveau"=>"1ERE G-T",
    #  "codeMef"=>"20110019110",
    #  "libelleLongMef"=>"PREMIERE GENERALE",
    #  "codeMefRatt"=>"20110019110",
    #  "classe"=>"3E4",
    #  "codeRegime"=>"2",
    #  "libelleRegime"=>"DP DAN",
    #  "codeStatut"=>"ST",
    #  "libelleLongStatut"=>"SCOLAIRE",
    #  "dateDebSco"=>"2023-09-05",
    #  "adhesionTransport"=>false
    # }

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

    def sygne_responsables
      # http://{context-root}/sygne/api/v{version.major}/eleves/{ine}/responsables + queryParams
      uri = URI(ENV['SYGNE_URL'] + '/eleves/001291528AA/responsables')
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
        JSON.parse(response.body).map do |responsable|
          {
            name: responsable['nomFamille'],
            first_name: responsable['prenom'],
            email: responsable['email'],
            phone: responsable['telephonePersonnel'],
            address: format_address(responsable['adrResidenceResp']),
            level: responsable['codeNiveauResponsabilite'],
            sexe: responsable['codeCivilite'] == '1' ? 'M' : 'F'
          }
        end
      else
        puts response
        raise "Failed to get sygne eleves : #{response.message}"
      end
    end

    def format_address(address_hash)
      "#{address_hash['adresseLigne1']}, #{address_hash['adresseLigne2']} #{address_hash['codePostal']} #{address_hash['libelleCommune']}"
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
