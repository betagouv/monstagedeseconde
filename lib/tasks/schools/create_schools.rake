namespace :schools do
  desc 'create "lycees" from csv file'
  task create_lycees: :environment do
    require 'csv'
    # Maine-et-Loire,49000,Angers,Claude Debussy,0491764B,"{""type"":""Point"",""coordinates"":[-0.515542,47.4892457]}" is the objective
    # Source sample:
    # 0820559M;Lycée;Lycée général, technologique et professionnel agricole de Montauban;1915 route de Bordeaux;82000.0;Montauban;44.03232875150177, 1.3154221508373432;1.0;1.0;1.0;;;True;;;;left_only;646.0;207.0
    # fields are the following:
    # uai,type_etab,nom_etablissement,adresse,code_postal,commune,position,voie_generale,voie_techno,voie_pro,etab_mere,nbeleves,voie_gt,rentree_scolaire,nombre_d_eleves,2ndes_gt,_merge,nbeleves_est,2des_est
    # their index are
    col_hash = { uai: 0, nom_etablissement: 2, adresse: 3, code_postal: 4, commune: 5, position: 6 }
    error_lines = []
    file_location_production = Rails.root.join('db/data_imports/annuaire_lycees.csv')
    file_location_review = Rails.root.join('db/data_imports/light_files/annuaire_lycees_light.csv')
    file_location = Rails.env.in?(%w[development review]) ? file_location_review : file_location_production
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      next if line_nr.zero?

      cells = row.to_s.split(';')

      uai = cells[col_hash[:uai]]
      next if uai.nil?
      next if School.find_by(code_uai: uai)

      nom_etablissement = cells[col_hash[:nom_etablissement]]
      adresse = cells[col_hash[:adresse]]
      code_postal = cells[col_hash[:code_postal]].to_i.to_s
      code_postal = "0#{code_postal}" if code_postal.size == 4
      commune = cells[col_hash[:commune]]
      position_array = cells[col_hash[:position]].split(',').map(&:to_f)
      longitude = position_array[0]
      latitude = position_array[1]
      if (longitude == 0.0 && latitude == 0.0) || (longitude.nil? || latitude.nil?)
        coordinates = Geofinder.coordinates("#{adresse}, #{code_postal} #{commune}")
        longitude = coordinates[0]
        latitude = coordinates[1]
      end

      school_params = {
        code_uai: uai,
        name: nom_etablissement,
        street: adresse,
        zipcode: code_postal,
        city: commune,
        coordinates: { longitude: longitude, latitude: latitude }
      }
      school = School.new(school_params)
      if school.valid?
        school.save
        print '.'
      else
        error_lines << ["Ligne #{line_nr}", school.name, school.errors.full_messages.join(', ')]
        print 'o'
      end
    end
    error_lines.each do |line|
      puts "Error #{line}"
    end
    puts "#{error_lines.size} errors"
    PrettyConsole.say_in_yellow 'Done with creating schools(lycées)'
  end

  desc 'create "collèges" and "lycees" from csv file'
  task create_colleges_lycees: :environment do
    file_location = Rails.root.join('db/data_imports/sources_EN/Liste_etablissements.csv')
    # uai;type_etab;nom_etablissement;adresse;code_postal;commune;voie_generale;voie_techno;nbeleves;zone_ep
    counter = 1
    error_lines = []
    CSV.foreach(file_location, 'r', headers: true, header_converters: :symbol, col_sep: ';').each do |row|
      counter += 1
      code_uai = row[:uai]
      School.find_by(code_uai: code_uai).present? && next

      name = row[:nom_etablissement]&.strip
      next if name.nil?

      adresse = row[:adresse]&.strip
      commune = row[:commune]&.strip

      code_postal = row[:code_postal]&.to_s&.strip
      code_postal = "0#{code_postal}" if code_postal.size == 4

      school_type = case row[:type_etab]
                    when 'Collège'
                      'college'
                    when 'Lycée'
                      'lycee'
                    else
                      print 'x'
                      'college_lycee'
                    end
      kind = case row[:zone_ep]
             when 'REP', 'rep'
               'rep'
             when 'REP+', 'rep+'
               'rep_plus'
             when 'QPV', 'qpv'
               'qpv'
             else
               ''
             end

      school_params = {
        code_uai: code_uai,
        name: name,
        street: adresse,
        zipcode: code_postal,
        city: commune,
        school_type: school_type,
        kind: kind
      }
      # searching for complementary data
      #
      ressource_file_location = Rails.root.join('db/data_imports/fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre.csv')
      # header is :
      # numero_uai;appellation_officielle;denomination_principale;patronyme_uai;secteur_public_prive_libe;adresse_uai;
      # lieu_dit_uai;boite_postale_uai;code_postal_uai;localite_acheminement_uai;libelle_commune;
      # coordonnee_x;coordonnee_y;EPSG;latitude;longitude;appariement;
      # localisation;nature_uai;nature_uai_libe;etat_etablissement;etat_etablissement_libe;
      # code_departement;code_region;code_academie;code_commune;libelle_departement;
      # libelle_region;libelle_academie;position;secteur_prive_code_type_contrat;
      # secteur_prive_libelle_type_contrat;code_ministere;
      # libelle_ministere;date_ouverture
      complementary_csv = CSV.read(ressource_file_location, headers: true, header_converters: :symbol,
                                                            col_sep: ';')
      complementary_data = complementary_csv.find { |row| row[:numero_uai] == code_uai }
      longitude = 0.0
      latitude = 0.0
      if complementary_data.present?
        longitude = complementary_data[:longitude]&.to_f || 0.0
        latitude = complementary_data[:latitude]&.to_f || 0.0
      else
        coordinates = Geofinder.coordinates("#{adresse}, #{code_postal} #{commune}")
        longitude = coordinates[0] || 0.0
        latitude = coordinates[1] || 0.0
      end
      if longitude == 0.0 && latitude == 0.0
        error = "Ligne #{counter}, #{school_params[:name]}, #{school_params[:street]}, #{school_params[:zipcode]} #{school_params[:city]}: no coordinates found"
        puts error
        error_lines << error
        next
      end
      school_params[:coordinates] = { longitude: longitude, latitude: latitude }

      if complementary_data.present?
        contract_code = complementary_data[:secteur_prive_code_type_contrat].presence
        school_params.merge!(contract_code: contract_code) if contract_code.present?
      end

      School.find_by(code_uai: school_params[:code_uai]).present? && next

      school = School.new(**school_params)
      if school.valid?
        school.save
        print '.'
      else
        error = "Ligne #{counter}, #{school.name}, #{school.errors.full_messages.join(', ')}"
        puts error
        error_lines << error
        puts '---'
      end
    end
    puts "#{error_lines.size} errors"
    PrettyConsole.say_in_yellow 'Done with creating schools(lycées)'
  end

  desc 'create class_rooms from csv file'
  task provide_with_class_rooms: :environment do
    import 'csv'
    # ACADEMIE	CODE_RNE (UAI)	ID_ETAB_SCONET (ETAB_UAJ_Id)	DIVISION (CLASSE)	EFFECTIF DECLARE
    # Aix-Marseille	0134252B	1188	2ND09	35
    # their index are
    col_hash = { academie: 0, code_uai: 1, 'id_etab_sco-net': 2, class_room_name: 3, class_size: 4 }
    error_lines = []
    file_location = Rails.root.join('db/data_imports/noms_de_classes.csv')
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      # with_index(2) : 2 is the offset to keep track of line number, taking into account the header
      next if line_nr.zero?

      cells = row.to_s.split(';')

      code_uai = cells[col_hash[:code_uai]]
      next if code_uai.nil?

      school = School.find_by(code_uai: code_uai)
      unless school.nil?
        print "#{school.name} - #{school.code_uai} missing data" if cells[col_hash[:class_room_name]].blank?
        class_room_name_new = false
        class_room = ClassRoom.find_or_create_by(name: cells[col_hash[:class_room_name]],
                                                 school: school) do |class_room|
          class_room.class_size = cells[col_hash[:class_size]]
          class_room.name = cells[col_hash[:class_room_name]]
          class_room.school_id = school.id
          class_room_name_new = true
        end
        class_room_name_new ? PrettyConsole.print_in_green('.') : PrettyConsole.print_in_red('.')
      end
    end
    school_without_class_rooms = School.where
                                       .not(id: ClassRoom.pluck(:school_id))
    puts ''
    PrettyConsole.say_in_yellow "There are #{school_without_class_rooms.count} schools without class rooms"
    school_without_class_rooms.each do |school|
      puts "#{school.code_uai} - #{school.name}"
    end
    PrettyConsole.say_in_yellow 'Done with creating class_rooms'
  end
end
