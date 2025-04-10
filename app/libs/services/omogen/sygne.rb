module Services::Omogen
  # Manage Captcha services
  class Sygne
    # 2434 : 3E SEGPA
    # 2115 : 4EME
    # 2116 : 3EME
    # 2211 : 2NDE G-T
    # 2433 : 4E SEGPA

    MEFSTAT4_CODES = %w[2115 2116 2211 2434 2433]
    def net_synchro
      uri = URI(ENV['NET_SYNCHRO_URL'])

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = "Bearer #{token}"
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
      request['Authorization'] = "Bearer #{token}"
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
      request['Authorization'] = "Bearer #{token}"

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
    #  [{
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
    # }]
    #
    # temporary method to import only 3 students for test purpose
    def sygne_import_by_schools_little(code_uai)
      counter = 0
      MEFSTAT4_CODES.each do |niveau|
        students = sygne_eleves(code_uai, niveau: niveau)
        students.each do |student|
          next if counter > 2

          student.make_student
          counter += 1
        end
      end
    end

    def sygne_import_by_schools(code_uai)
      MEFSTAT4_CODES.each do |niveau|
        students = sygne_eleves(code_uai, niveau: niveau)
        students.each do |student|
          ActiveRecord::Base.transaction do
            student.make_student
          end
        end
      end
    end

    def sygne_schools(code_uai = '0590116F')
      uri = URI("#{ENV['SYGNE_URL']}/etablissements/#{code_uai}/eleves)")
      schools_in_data = []
      response = sygne_eleves(uri)
      case response
      when Net::HTTPSuccess
        schools_in_data << JSON.parse(response.body)
      when Net::HTTPNotFound
        puts response.body
        Rails.logger.error "Failed to get sygne eleves : #{response.message}"
      end
      print 'x'
      schools_in_data
    end

    def sygne_responsables(ine = '001291528AA')
      # http://{context-root}/sygne/api/v{version.major}/eleves/{ine}/responsables + queryParams

      uri = URI("#{ENV['SYGNE_URL']}/eleves/#{ine}/responsables")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = "Bearer #{@token}"
      request['Compression-Zip'] = 'non'

      response = http.request(request)
      # [{ 'email' => 't-t@hotmail.fr',
      #    'nomFamille' => 't PPPEPF',
      #    'rcar' => 't-dgfdsq',
      #    'codeCivilite' => 't',
      #    'prenom' => 't-ffd',
      #    'codePcs' => 'tfds',
      #    'accepteSms' => 'tfsqdf',
      #    'codeLienEleveResponsable' => 'tfdsqf',
      #    'codeNiveauResponsabilite' => 'tfdsq',
      #    'percoitAides' => 'tfsdq',
      #    'paieFraisScolaires' => 'tfqsd',
      #    'telephonePortable' => 'dfqdf',
      #    'divulgationAdresse' => 'tfsdqfq',
      #    'adrResidenceResp' => { 't' => 't', 'codePostal' => 't', 'codePays' => 't',
      #                            'adresseLigne3' => 't RUE DE LA FONTAINE', 'libelleCommune' => 't' },
      #    'libelleLienEleveResponsable' => 't',
      #    'libelleNiveauResponsabilite' => 't LEGAL',
      #    'libellePcs' => 't artisan-commerçant-chef entrepr' },
      #  { 'email' => 't@hotmail.fr',
      #    'nomFamille' => 't',
      #    'rcar' => 't-fdfds',
      #    'codeCivilite' => 't',
      #    'prenom' => 't',
      #    'codePcs' => 't',
      #    'accepteSms' => 't',
      #    'codeLienEleveResponsable' => 't',
      #    'codeNiveauResponsabilite' => 't',
      #    'percoitAides' => 't',
      #    'paieFraisScolaires' => 't',
      #    'telephonePortable' => 'tffdsfq',
      #    'divulgationAdresse' => 't',
      #    'adrResidenceResp' => { 't' => 't', 'codePostal' => 't', 'codePays' => 't',
      #                            'adresseLigne2' => 't fsdqfsq', 'adresseLigne3' => 't', 'libelleCommune' => 't' },
      #    'libelleLienEleveResponsable' => 't',
      #    'libelleNiveauResponsabilite' => 't LEGAL',
      #    'libellePcs' => 't' }]

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
      end
    end

    def sygne_eleves(code_uai, niveau:)
      students = []
      uri = URI("#{ENV['SYGNE_URL']}/etablissements/#{code_uai}/eleves?niveau=#{niveau}")
      response = sygne_eleves_request(uri)
      case response
      when Net::HTTPSuccess
        # puts response.body
        # puts JSON.parse(response.body)
        data_students = JSON.parse(response.body, symbolize_names: true)
        data_students.each do |data_student|
          if data_student.fetch(:codeMef, false) && Grade.code_mef_ok?(code_mef: data_student[:codeMef])
            students << SygneEleve.new(data_student)
          end
        end
      when Net::HTTPNotFound
        puts response.body
        error_message = "Failed to get sygne eleves  - HTTPNotFound - #{response.message}"
        Rails.logger.error error_message
        raise error_message
      when Net::HTTPForbidden
        error_message = "Failed to get sygne eleves - 403 - Forbidden Access | #{response.try(:message)}"
        Rails.logger.error error_message
        raise error_message
      else
        puts response
        error_message = "Failed to get sygne eleves | #{response.try(:message)}"
        Rails.logger.error error_message
        raise error_message
      end
      students
    end

    def sygne_responsable(ine)
      response = sygne_responsables_request(ine)
      case response
      when Net::HTTPSuccess
        responsibles = JSON.parse(response.body, symbolize_names: true)
        return nil unless responsibles.is_a?(Array) && responsibles.any?

        responsibles.sort_by! { |responsible| responsible[:codeNiveauResponsabilite] }
        Services::Omogen::SygneResponsible.new(responsibles.first)
      else
        puts response
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

    attr_reader :token

    private

    def sygne_eleves_request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri, headers)
      http.request(request)
    end

    def headers
      { 'Authorization': "Bearer #{token}", 'Compression-Zip': 'non' }
    end

    def sygne_responsables_request(ine)
      # http://{context-root}/sygne/api/v{version.major}/eleves/{ine}/responsables + queryParams
      uri = URI("#{ENV['SYGNE_URL']}/eleves/#{ine}/responsables")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri, headers)
      http.request(request)
    end

    def format_address(address_hash)
      "#{address_hash[:adresseLigne1]}, #{address_hash[:adresseLigne2]} #{address_hash[:codePostal]} #{address_hash[:libelleCommune]}"
    end
  end
end
