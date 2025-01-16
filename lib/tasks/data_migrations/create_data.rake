require 'pretty_console'
namespace :data_migrations do
  desc 'create sectors'
  task add_sectors: :environment do
    {
      'Agroéquipement' => 's1',
      'Architecture, urbanisme et paysage' => 's2',
      'Armée - Défense' => 's3',
      'Art et design' => 's4',
      "Artisanat d'art" => 's5',
      'Arts du spectacle' => 's6',
      'Audiovisuel' => 's7',
      'Automobile' => 's8',
      'Banque et assurance' => 's9',
      'Bâtiment et travaux publics (BTP)' => 's10',
      'Bien-être' => 's11',
      'Commerce et distribution' => 's12',
      'Communication' => 's13',
      'Comptabilité, gestion, ressources humaines' => 's14',
      'Conseil et audit' => 's15',
      'Construction aéronautique, ferroviaire et navale' => 's16',
      'Culture et patrimoine' => 's17',
      'Droit et justice' => 's18',
      'Édition, librairie, bibliothèque' => 's19',
      'Électronique' => 's20',
      'Énergie' => 's21',
      'Enseignement' => 's22',
      'Environnement' => 's23',
      'Filiere bois' => 's24',
      'Fonction publique' => 's25',
      'Hôtellerie, restauration' => 's26',
      'Immobilier, transactions immobilières' => 's27',
      'Industrie alimentaire' => 's28',
      'Industrie chimique' => 's29',
      'Industrie, ingénierie industrielle' => 's30',
      'Informatique et réseaux' => 's31',
      'Jeu vidéo' => 's32',
      'Journalisme' => 's33',
      'Logistique et transport' => 's34',
      'Maintenance' => 's35',
      'Marketing, publicité' => 's36',
      'Mécanique' => 's37',
      "Métiers d'art" => 's38',
      'Mode' => 's39',
      'Papiers Cartons' => 's40',
      'Paramédical' => 's41',
      'Recherche' => 's42',
      'Santé' => 's43',
      'Sécurité' => 's44',
      'Services postaux' => 's45',
      'Social' => 's46',
      'Sport' => 's47',
      'Tourisme' => 's48',
      'Traduction, interprétation' => 's49',
      'Verre, béton, céramique' => 's50'
    }.map do |sector_name, sector_uuid|
      next if Sector.find_by(name: sector_name)

      Sector.create!(name: sector_name, uuid: sector_uuid)
      print '.'
    end
  end

  desc 'create "lycees" from csv file'
  task create_lycees: :environment do
    import 'csv'
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

  desc 'create academies and regions'
  task populate_academy_regions: :environment do
    [
      'Auvergne-Rhône-Alpes',
      'Bourgogne-Franche-Comté',
      'Bretagne',
      'Centre-Val de Loire',
      'Corse',
      'Grand Est',
      'Guadeloupe',
      'Guyane',
      'Nouvelle-Calédonie',
      'Polynésie française',
      'Hauts-de-France',
      'Ile-de-France',
      'La Réunion',
      'Martinique',
      'Mayotte',
      'Normandie',
      'Nouvelle-Aquitaine',
      'Occitanie',
      'Pays de la Loire',
      "Provence-Alpes-Côte d'Azur"
    ].each do |academy_region_name|
      next if AcademyRegion.find_by(name: academy_region_name)

      AcademyRegion.create!(name: academy_region_name)
      print ' .'
    end
  end

  desc 'create academies'
  task populate_academies: :environment do
    {
      'Auvergne-Rhône-Alpes': [
        { 'Académie de Clermont-Ferrand': 'ac-clermont.fr' },
        { 'Académie de Grenoble': 'ac-grenoble.fr' },
        { 'Académie de Lyon': 'ac-lyon.fr' }
      ],
      'Bourgogne-Franche-Comté': [
        { 'Académie de Besançon': 'ac-besancon.fr' },
        { 'Académie de Dijon': 'ac-dijon.fr' }
      ],
      'Bretagne': [
        { 'Académie de Rennes': 'ac-rennes.fr' }
      ],
      'Centre-Val de Loire': [
        { "Académie d'OrléansTours": 'ac-orleans-tours.fr' }
      ],
      'Corse': [
        { 'Académie de Corse': 'ac-corse.fr' }
      ],
      'Grand Est': [
        { 'Académie de Nancy-Metz': 'ac-nancy-metz.fr' },
        { 'Académie de Reims': 'ac-reims.fr' },
        { 'Académie de Strasbourg': 'ac-strasbourg.fr' }
      ],
      'Guadeloupe': [
        { 'Académie de la Guadeloupe': 'ac-guadeloupe.fr' }
      ],
      'Guyane': [
        { 'Académie de la Guyane': 'ac-guyane.fr' }
      ],
      'Nouvelle-Calédonie': [
        { 'Académie de la Nouvelle-Calédonie': 'ac-noumea.nc' }
      ],
      'Polynésie française': [
        { 'Académie de la Polynésie française': 'ac-polynesie.pf' }
      ],
      'Hauts-de-France': [
        { "Académie d'Amiens": 'ac-amiens.fr' },
        { 'Académie de Lille': 'ac-lille.fr' }
      ],
      'Ile-de-France': [
        { 'Académie de Créteil': 'ac-creteil.fr' },
        { 'Académie de Paris': 'ac-paris.fr' },
        { 'Académie de Versailles': 'ac-versailles.fr' }
      ],
      'La Réunion': [
        { 'Académie de La Réunion': 'ac-reunion.fr' }
      ],
      'Martinique': [
        { 'Académie de Martinique': 'ac-martinique.fr' }
      ],
      'Mayotte': [
        { 'Académie de Mayotte': 'ac-mayotte.fr' }
      ],
      'Normandie': [
        { 'Académie de Normandie': 'ac-normandie.fr' }
      ],
      'Nouvelle-Aquitaine': [
        { 'Académie de Bordeaux': 'ac-bordeaux.fr' },
        { 'Académie de Limoges': 'ac-limoges.fr' },
        { 'Académie de Poitiers': 'ac-poitiers.fr' }
      ],
      'Occitanie': [
        { 'Académie de Montpellier': 'ac-montpellier.fr' },
        { 'Académie de Toulouse': 'ac-toulouse.fr' }
      ],
      'Pays de la Loire': [
        { 'Académie de Nantes': 'ac-nantes.fr' }
      ],
      "Provence-Alpes-Côte d'Azur": [
        { "Académie d'Aix-Marseille": 'ac-aix-marseille.fr' },
        { 'Académie de Nice': 'ac-nice.fr' }
      ]
    }.each do |academy_region_name, academies|
      academy_region = AcademyRegion.find_by(name: academy_region_name)

      academies.each do |academy_hash|
        academy_hash.each do |academy_name, email_domain|
          next if Academy.find_by(name: academy_name)

          Academy.create!(name: academy_name, academy_region:, email_domain:)
          print ' .'
        end
      end
    end
  end

  desc 'update departments with academies'
  task update_departments_with_academies: :environment do
    {
      "Académie de Clermont-Ferrand": [
        { "03": 'Allier' },
        { "15": 'Cantal' },
        { "43": 'Haute-Loire' },
        { "63": 'Puy-de-Dôme' }
      ],
      "Académie de Grenoble": [
        { "07": 'Ardèche' },
        { "26": 'Drôme' },
        { "38": 'Isère' },
        { "74": 'Haute-Savoie' },
        { "73": 'Savoie' }
      ],
      "Académie de Lyon": [
        { "01": 'Ain' },
        { "42": 'Loire' },
        { "69": 'Rhône' }
      ],
      "Académie de Besançon": [
        { "25": 'Doubs' },
        { "39": 'Jura' },
        { "70": 'Haute-Saône' },
        { "90": 'Territoire de Belfort' }
      ],
      "Académie de Dijon": [
        { "21": "Côte-d'Or" },
        { "58": 'Nièvre' },
        { "71": 'Saône-et-Loire' },
        { "89": 'Yonne' }
      ],
      "Académie de Rennes": [
        { "22": "Côtes-d'Armor" },
        { "29": 'Finistère' },
        { "35": 'Ille-et-Vilaine' },
        { "56": 'Morbihan' }
      ],
      "Académie d'OrléansTours": [
        { "18": 'Cher' },
        { "28": 'Eure-et-Loir' },
        { "36": 'Indre' },
        { "37": 'Indre-et-Loire' },
        { "41": 'Loir-et-Cher' },
        { "45": 'Loiret' }
      ],
      "Académie de Corse": [
        { "2A": 'Corse-du-Sud' },
        { "2B": 'Haute-Corse' }
      ],
      "Académie de Nancy-Metz": [
        { "54": 'Meurthe-et-Moselle' },
        { "55": 'Meuse' },
        { "57": 'Moselle' },
        { "88": 'Vosges' }
      ],
      "Académie de Reims": [
        { "08": 'Ardennes' },
        { "10": 'Aube' },
        { "51": 'Marne' },
        { "52": 'Haute-Marne' }
      ],
      "Académie de Strasbourg": [
        { "67": 'Bas-Rhin' },
        { "68": 'Haut-Rhin' }
      ],
      "Académie de la Guadeloupe": [
        { "971": 'Guadeloupe' }
      ],
      "Académie de la Guyane": [
        { "973": 'Guyane' }
      ],
      "Académie de la Nouvelle-Calédonie": [
        { "988": 'Nouvelle-Calédonie' }
      ],
      'Académie de la Polynésie française': [
        { "987": 'Polynésie française' }
      ],
      'Académie de La Réunion': [
        { "974": 'La Réunion' }
      ],
      'Académie de Mayotte': [
        { "976": 'Mayotte' }
      ],
      "Académie d'Amiens": [
        { "02": 'Aisne' },
        { "60": 'Oise' },
        { "80": 'Somme' }
      ],
      "Académie de Lille": [
        { "59": 'Nord' },
        { "62": 'Pas-de-Calais' }
      ],
      "Académie de Créteil": [
        { "77": 'Seine-et-Marne' },
        { "93": 'Seine-Saint-Denis' },
        { "94": 'Val-de-Marne' }
      ],
      "Académie de Paris": [
        { "75": 'Paris' }
      ],
      "Académie de Versailles": [
        { "78": 'Yvelines' },
        { "91": 'Essonne' },
        { "92": 'Hauts-de-Seine' },
        { "95": "Val-d'Oise" }
      ],
      "Académie de Martinique": [
        { "972": 'Martinique' }
      ],
      "Académie de Normandie": [
        { "14": 'Calvados' },
        { "27": 'Eure' },
        { "50": 'Manche' },
        { "61": 'Orne' },
        { "76": 'Seine-Maritime' }
      ],
      "Académie de Bordeaux": [
        { "24": 'Dordogne' },
        { "33": 'Gironde' },
        { "40": 'Landes' },
        { "47": 'Lot-et-Garonne' },
        { "64": 'Pyrénées-Atlantiques' }
      ],
      "Académie de Limoges": [
        { "19": 'Corrèze' },
        { "23": 'Creuse' },
        { "87": 'Haute-Vienne' }
      ],
      "Académie de Poitiers": [
        { "16": 'Charente' },
        { "17": 'Charente-Maritime' },
        { "79": 'Deux-Sèvres' },
        { "86": 'Vienne' }
      ],
      "Académie de Montpellier": [
        { "11": 'Aude' },
        { "30": 'Gard' },
        { "34": 'Hérault' },
        { "48": 'Lozère' },
        { "66": 'Pyrénées-Orientales' }
      ],
      "Académie de Toulouse": [
        { "09": 'Ariège' },
        { "12": 'Aveyron' },
        { "31": 'Haute-Garonne' },
        { "32": 'Gers' },
        { "46": 'Lot' },
        { "65": 'Hautes-Pyrénées' },
        { "81": 'Tarn' },
        { "82": 'Tarn-et-Garonne' }
      ],
      "Académie de Nantes": [
        { "44": 'Loire-Atlantique' },
        { "49": 'Maine-et-Loire' },
        { "53": 'Mayenne' },
        { "72": 'Sarthe' },
        { "85": 'Vendée' }
      ],
      "Académie d'Aix-Marseille": [
        { "04": 'Alpes-de-Haute-Provence' },
        { "05": 'Hautes-Alpes' },
        { "13": 'Bouches-du-Rhône' },
        { "84": 'Vaucluse' }
      ],
      "Académie de Nice": [
        { "06": 'Alpes-Maritimes' },
        { "83": 'Var' }
      ]
    }.each do |academy_name, departments|
      academy = Academy.find_by(name: academy_name)

      departments.each do |department_hashes|
        department_hashes.each do |code, department_name|
          Department.find_by(name: department_name).update!(academy: academy)
          # Department.create!(name: department_name, code:, academy:)
          print ' .'
        end
      end
    end
  end

  desc 'add_missing_grades_to_former_internship_offers'
  task :add_missing_grades_to_former_internship_offers, [] => :environment do
    PrettyConsole.announce_task('Adding missing grades to former internship offers') do
      InternshipOffer.kept.find_each do |offer|
        next if offer.grades.include?(Grade.seconde)

        offer.grades = [Grade.seconde]
        offer.save
        print '.'
      end
    end
  end

  desc 'used when migrating 2024 to 2025'
  task :offers_renewed, [] => :environment do |args|
    PrettyConsole.announce_task('Renewing internship offers') do
      # in storage/tmp/offers_to_renew.csv there a list of emails of employers which offers have to be renewed
      CSV.foreach(Rails.root.join('storage/tmp/offers_to_renew_from_email.csv')) do |row|
        email = row[0]
        employer = Users::Employer.find_by(email: email)
        next if employer.nil?

        employer.internship_offers
                .kept
                .where(hidden_duplicate: false)
                .find_each do |offer|
          puts offer.grades
          next unless offer.grades.include?(Grade.seconde)

          weeks_to_add = []
          new_internship_offer = offer.dup

          if new_internship_offer.period == 0
            weeks_to_add << SchoolTrack::Seconde.both_weeks
          elsif new_internship_offer.period == 1
            weeks_to_add << SchoolTrack::Seconde.first_week
          elsif new_internship_offer.period == 2
            weeks_to_add << SchoolTrack::Seconde.second_weeks
          end
          new_internship_offer.weeks = weeks_to_add.flatten
          new_internship_offer.grades = [Grade.seconde]
          new_internship_offer.weekly_hours = offer.weekly_hours
          new_internship_offer.published_at = Date.today
          new_internship_offer.aasm_state = 'published'
          new_internship_offer.save

          offer.hidden_duplicate = true
          offer.weeks = offer.weeks & Week.of_past_school_years || []
          offer.save
          offer.unpublish!
        end
      end
    end
  end

  # ===============================================
  # Crafts section
  # ===============================================

  desc 'create craft fields'
  task create_craft_fields: :environment do
    import 'csv'
    col_hash = {
      craft_field_letter: 0,
      craft: 1,
      detailed_craft: 2,
      name: 3,
      ogr_code: 4
    }
    file_location_production = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
    file_location_review = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
    file_location = Rails.env.in?(%w[development review]) ? file_location_review : file_location_production
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      next if line_nr.zero?

      cells = row.to_s.split(';').map(&:strip)
      next unless cells[col_hash[:craft]].blank? && cells[col_hash[:detailed_craft]].blank?

      craft_field = CraftField.find_or_create_by(letter: cells[col_hash[:craft_field_letter]]) do |craft_field|
        PrettyConsole.print_in_green '.'
        craft_field.name = cells[col_hash[:name]]
        craft_field.letter = cells[col_hash[:craft_field_letter]]
      end
    end
    puts ''
    PrettyConsole.say_in_yellow 'Done with creating craft fields'
  end

  desc 'create crafts'
  task create_crafts: :environment do
    import 'csv'
    col_hash = {
      craft_field_letter: 0,
      craft: 1,
      detailed_craft: 2,
      name: 3,
      ogr_code: 4
    }
    file_location_production = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
    file_location_review = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
    file_location = Rails.env.in?(%w[development review]) ? file_location_review : file_location_production
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      next if line_nr.zero?

      cells = row.to_s.split(';').map(&:strip)
      next if cells[col_hash[:craft]].blank? && cells[col_hash[:detailed_craft]].blank?
      next unless cells[col_hash[:detailed_craft]].blank?

      Craft.joins(:craft_field)
           .where(number: cells[col_hash[:craft]])
           .where(craft_field: { letter: cells[col_hash[:craft_field_letter]] })
           .first_or_create do |craft|
        PrettyConsole.print_in_green '.'
        craft.name = cells[col_hash[:name]]
        craft.number = cells[col_hash[:craft]]
        craft_field = CraftField.find_by(letter: cells[col_hash[:craft_field_letter]])
        craft.craft_field = craft_field
      end
    end
    puts ''
    PrettyConsole.say_in_yellow 'Done with creating crafts'
  end

  desc 'create detailed_crafts'
  task create_detailed_crafts: :environment do
    import 'csv'
    col_hash = {
      craft_field_letter: 0,
      craft: 1,
      detailed_craft: 2,
      name: 3,
      ogr_code: 4
    }
    file_location_production = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
    file_location_review = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
    file_location = Rails.env.in?(%w[development review]) ? file_location_review : file_location_production
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      next if line_nr.zero?

      cells = row.to_s.split(';').map(&:strip)
      next if cells[col_hash[:craft]].blank? || cells[col_hash[:detailed_craft]].blank?
      next unless cells[col_hash[:ogr_code]].blank?

      DetailedCraft.joins(craft: :craft_field)
                   .where(craft: { number: cells[col_hash[:craft]] })
                   .where(craft_field: { letter: cells[col_hash[:craft_field_letter]] })
                   .where(number: cells[col_hash[:detailed_craft]])
                   .first_or_create do |detailed_craft|
        PrettyConsole.print_in_green '.'
        detailed_craft.name = cells[col_hash[:name]]
        detailed_craft.number = cells[col_hash[:detailed_craft]]
        craft = Craft.find_by(number: cells[col_hash[:craft]])
        detailed_craft.craft = craft
      end
    end
    puts ''
    PrettyConsole.say_in_yellow 'Done with creating detailed crafts'
  end

  desc 'create coded_crafts'
  task create_coded_crafts: :environment do
    import 'csv'
    col_hash = {
      craft_field_letter: 0,
      craft: 1,
      detailed_craft: 2,
      name: 3,
      ogr_code: 4
    }
    file_location_production = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
    file_location_review = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
    file_location = Rails.env.in?(%w[development review]) ? file_location_review : file_location_production
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      next if line_nr.zero?

      cells = row.to_s.split(';').map(&:strip)
      next if cells[col_hash[:craft]].blank? || cells[col_hash[:detailed_craft]].blank?
      next if cells[col_hash[:ogr_code]].blank?

      CodedCraft.joins(detailed_craft: { craft: :craft_field })
                .where(detailed_craft: { number: cells[col_hash[:detailed_craft]] })
                .where(craft: { number: cells[col_hash[:craft]] })
                .where(craft_field: { letter: cells[col_hash[:craft_field_letter]] })
                .where(ogr_code: cells[col_hash[:ogr_code]])
                .first_or_create(ogr_code: cells[col_hash[:ogr_code]]) do |coded_craft|
        PrettyConsole.print_in_green '.'
        coded_craft.name = cells[col_hash[:name]]
        coded_craft.ogr_code = cells[col_hash[:ogr_code]]
        detailed_craft = DetailedCraft.find_by(number: cells[col_hash[:detailed_craft]])
        coded_craft.detailed_craft = detailed_craft
      end
    end
    puts ''
    PrettyConsole.say_in_yellow 'Done with creating coded crafts'
  end

  desc 'populate crafts with 4 tables'
  task populate_crafts: %w[data_migrations:create_craft_fields
                           data_migrations:create_crafts
                           data_migrations:create_detailed_crafts
                           data_migrations:create_coded_crafts]

  desc 'populate grades'
  task populate_grades: :environment do
    Grade.find_or_create_by!(short_name: :seconde, name: 'seconde générale et technologique',
                             school_year_end_month: '06', school_year_end_day: '30')
    Grade.find_or_create_by!(short_name: :troisieme, name: 'troisieme générale', school_year_end_month: '05',
                             school_year_end_day: '31')
    Grade.find_or_create_by!(short_name: :quatrieme, name: 'quatrieme générale',
                             school_year_end_month: '05', school_year_end_day: '31')
  end
end
