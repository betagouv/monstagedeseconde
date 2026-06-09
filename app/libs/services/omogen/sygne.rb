module Services::Omogen
  class Sygne
    include ::Services::ApiRequestsHelper
    # 2434 : 3E SEGPA
    # 2115 : 4EME
    # 2116 : 3EME
    # 2211 : 2NDE G-T
    # 2433 : 4E SEGPA

    MEFSTAT4_CODES = %w[2115 2116 2211 2434 2433]
    def net_synchro
      uri = URI(ENV["NET_SYNCHRO_URL"])

      response = perform_http_request(uri, {
                                        "Code-Application" => "FRE",
                                        "Code-RNE" => "0595121W",
                                        "Compression-Zip" => "non",
                                        "Contexte-Annee-Scolaire" => "2021",
                                        "Perimetre-Applicatif" => "A09"
                                      })

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "Failed to get netsynchro resource : #{response.message}"
      end
    end

    def sygne
      uri = URI(ENV["SYGNE_URL"])

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"

      request = Net::HTTP::Get.new(uri.request_uri)
      request["Authorization"] = "Bearer #{token}"
      request["Code-Application"] = "FRE"
      request["Code-RNE"] = "0595121W"
      request["Compression-Zip"] = "non"
    end

    def sygne_status
      uri = URI(ENV["SYGNE_URL"] + "/version")
      response = perform_http_request(uri)

      case response
      when Net::HTTPSuccess
        response.body
      else
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
      process_mefstat4_codes(code_uai, limit: 3)
    end

    def sygne_import_by_schools(code_uai)
      process_mefstat4_codes(code_uai)
    end

    def sygne_schools(code_uai = "0590116F")
      uri = URI("#{ENV['SYGNE_URL']}/etablissements/#{code_uai}/eleves)")
      schools_in_data = []
      response = get_request(uri, get_default_headers)
      case response
      when Net::HTTPSuccess
        schools_in_data << JSON.parse(response.body)
      when Net::HTTPNotFound
        puts response.body
        Rails.logger.error "Failed to get sygne eleves : #{response.message}"
      end
      print "x"
      schools_in_data
    end

    def sygne_responsables(ine = "001291528AA")
      # http://{context-root}/sygne/api/v{version.major}/eleves/{ine}/responsables + queryParams

      uri = URI("#{ENV['SYGNE_URL']}/eleves/#{ine}/responsables")
      response = perform_http_request(uri, { "Compression-Zip" => "non" })

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
            name: responsable["nomFamille"],
            first_name: responsable["prenom"],
            email: responsable["email"],
            phone: responsable["telephonePersonnel"],
            address: format_address(responsable["adrResidenceResp"]),
            level: responsable["codeNiveauResponsabilite"],
            sexe: responsable["codeCivilite"] == "1" ? "M" : "F"
          }
        end
      end
    end

    def sygne_eleves(code_uai, niveau:)
      students = []
      uri = URI("#{ENV['SYGNE_URL']}/etablissements/#{code_uai}/eleves?niveau=#{niveau}")
      response = get_with_token_refresh(uri)
      case response
      when Net::HTTPSuccess
        data_students = JSON.parse(response.body, symbolize_names: true)
        data_students.each do |data_student|
          if data_student.fetch(:codeMef, false) && Grade.code_mef_ok?(code_mef: data_student[:codeMef])
            students << SygneEleve.new(data_student)
          end
        end
      when Net::HTTPNotFound
        raise SygneApiError, "sygne_eleves 404 | uai=#{code_uai} niveau=#{niveau}"
      when Net::HTTPForbidden
        raise SygneApiError, "sygne_eleves 403 | uai=#{code_uai} niveau=#{niveau}"
      when Net::HTTPUnauthorized
        raise SygneApiError, "sygne_eleves 401 token expired | uai=#{code_uai} niveau=#{niveau}"
      when Net::HTTPServerError
        raise SygneApiError, "sygne_eleves #{response.code} | uai=#{code_uai} niveau=#{niveau}"
      else
        raise SygneApiError, "sygne_eleves unexpected HTTP #{response.code} | uai=#{code_uai} niveau=#{niveau}"
      end
      students
    rescue JSON::ParserError => e
      raise SygneApiError, "sygne_eleves JSON invalide | uai=#{code_uai} niveau=#{niveau} | #{e.message.truncate(120)}"
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise SygneApiError, "sygne_eleves timeout | uai=#{code_uai} niveau=#{niveau} | #{e.class}"
    rescue SocketError => e
      raise SygneApiError, "sygne_eleves réseau | uai=#{code_uai} niveau=#{niveau} | #{e.message.truncate(120)}"
    end

    # GET /eleves/{ine} : récupère la scolarité d'un seul élève à partir de son INE.
    # Renvoie un SygneEleve (ou nil si l'élève est introuvable / sans scolarité exploitable).
    # NB : la forme exacte du JSON n'est pas documentée ; normalize_eleve_payload gère une
    # réponse à plat, un objet `scolarite` imbriqué ou un tableau `scolarites`.
    def sygne_eleve(ine)
      uri = URI("#{ENV['SYGNE_URL']}/eleves/#{ine}")
      response = get_with_token_refresh(uri)
      case response
      when Net::HTTPSuccess
        hash = normalize_eleve_payload(JSON.parse(response.body, symbolize_names: true), ine: ine)
        hash && SygneEleve.new(hash)
      when Net::HTTPNotFound
        nil
      else
        raise SygneApiError, "sygne_eleve #{response.code} | ine=#{ine}"
      end
    rescue JSON::ParserError => e
      raise SygneApiError, "sygne_eleve JSON invalide | ine=#{ine} | #{e.message.truncate(120)}"
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise SygneApiError, "sygne_eleve timeout | ine=#{ine} | #{e.class}"
    rescue SocketError => e
      raise SygneApiError, "sygne_eleve réseau | ine=#{ine} | #{e.message.truncate(120)}"
    end

    # Compte les élèves éligibles par classe sans rien persister.
    # Renvoie un Hash : [nom_classe, grade_id] => { count:, grade_id:, female:, male: }
    def sygne_count_by_school(code_uai)
      tally = Hash.new { |hash, key| hash[key] = { count: 0, grade_id: nil, female: 0, male: 0 } }
      MEFSTAT4_CODES.each do |niveau|
        sygne_eleves(code_uai, niveau: niveau).each do |eleve|
          next if eleve.grade.blank? || eleve.classe.blank?

          key = [eleve.classe, eleve.grade.id]
          tally[key][:count] += 1
          tally[key][:grade_id] = eleve.grade.id
          tally[key][:female] += 1 if eleve.gender == 'f'
          tally[key][:male] += 1 if eleve.gender == 'm'
        end
      end
      tally
    end

    def sygne_responsable(ine)
      uri = URI("#{ENV['SYGNE_URL']}/eleves/#{ine}/responsables")
      response = get_with_token_refresh(uri)
      case response
      when Net::HTTPSuccess
        responsibles = JSON.parse(response.body, symbolize_names: true)
        return nil unless responsibles.is_a?(Array) && responsibles.any?

        responsibles.sort_by! { |responsible| responsible[:codeNiveauResponsabilite] }
        Services::Omogen::SygneResponsible.new(responsibles.first)
      when Net::HTTPNotFound
        nil
      else
        raise SygneApiError, "sygne_responsable #{response.code} | ine=#{ine}"
      end
    rescue JSON::ParserError => e
      raise SygneApiError, "sygne_responsable JSON invalide | ine=#{ine} | #{e.message.truncate(120)}"
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise SygneApiError, "sygne_responsable timeout | ine=#{ine} | #{e.class}"
    rescue SocketError => e
      raise SygneApiError, "sygne_responsable réseau | ine=#{ine} | #{e.message.truncate(120)}"
    end

    def initialize
      @token = fetch_oauth_token
    end

    attr_reader :token

    private

    # Aplatit la réponse de GET /eleves/{ine} vers les clés symboles attendues par
    # SygneEleve#initialize. Tolère trois formes : à plat, objet `scolarite`, tableau
    # `scolarites` (on garde la scolarité la plus récente). Renvoie nil si pas de codeMef.
    def normalize_eleve_payload(payload, ine:)
      return nil if payload.blank?

      sco = payload[:scolarite] ||
            Array(payload[:scolarites]).max_by { |scolarite| scolarite[:anneeScolaire].to_i } ||
            payload
      return nil if sco[:codeMef].blank?

      {
        ine: payload[:ine] || ine,
        nom: payload[:nom],
        prenom: payload[:prenom],
        dateNaissance: payload[:dateNaissance],
        codeSexe: payload[:codeSexe],
        codeUai: sco[:codeUai],
        anneeScolaire: sco[:anneeScolaire],
        niveau: sco[:niveau],
        libelleNiveau: sco[:libelleNiveau],
        codeMef: sco[:codeMef],
        classe: sco[:classe],
        codeStatut: sco[:codeStatut]
      }
    end

    def perform_http_request(uri, additional_headers = {})
      get_request(uri, default_headers).merge(additional_headers)
    end

    def default_headers
      { 'Authorization': "Bearer #{token}", 'Compression-Zip': "non" }
    end

    def get_with_token_refresh(uri)
      response = get_request(uri, default_headers)
      return response unless response.is_a?(Net::HTTPUnauthorized)

      Rails.logger.warn("refreshing Sygne OAuth token after 401 on #{uri}")
      @token = fetch_oauth_token
      get_request(uri, default_headers)
    end

    def process_mefstat4_codes(code_uai, limit: nil)
      counter = 0
      MEFSTAT4_CODES.each do |niveau|
        students = sygne_eleves(code_uai, niveau: niveau)
        students.each do |student|
          break if limit && counter >= limit

          ActiveRecord::Base.transaction do
            success = student.make_student
            counter += 1 if limit && success
          end
        end
      end
    end

    def fetch_oauth_token
      response = post_form_request(url: ENV["OMOGEN_OAUTH_URL"],
                                   params: {
                                     grant_type: "client_credentials",
                                     client_id: ENV["OMOGEN_CLIENT_ID"],
                                     client_secret: ENV["OMOGEN_CLIENT_SECRET"]
                                   })
      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)["access_token"]
      else
        raise "Failed to get OAuth token: #{response.message}"
      end
    end

    def format_address(address_hash)
      "#{address_hash[:adresseLigne1]}, #{address_hash[:adresseLigne2]} #{address_hash[:codePostal]} #{address_hash[:libelleCommune]}"
    end
  end
end
