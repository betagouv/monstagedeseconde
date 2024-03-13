namespace :data_migrations do
  desc 'create sectors'
  task add_sectors: :environment do
    {
      "Agroéquipement" => "s1",
      "Architecture, urbanisme et paysage" => "s2",
      "Armée - Défense" => "s3",
      "Art et design" => "s4",
      "Artisanat d'art" => "s5",
      "Arts du spectacle" => "s6",
      "Audiovisuel" => "s7",
      "Automobile" => "s8",
      "Banque et assurance" => "s9",
      "Bâtiment et travaux publics (BTP)" => "s10",
      "Bien-être" => "s11",
      "Commerce et distribution" => "s12",
      "Communication" => "s13",
      "Comptabilité, gestion, ressources humaines" => "s14",
      "Conseil et audit" => "s15",
      "Construction aéronautique, ferroviaire et navale" => "s16",
      "Culture et patrimoine" => "s17",
      "Droit et justice" => "s18",
      "Édition, librairie, bibliothèque" => "s19",
      "Électronique" => "s20",
      "Énergie" => "s21",
      "Enseignement" => "s22",
      "Environnement" => "s23",
      "Filiere bois" => "s24",
      "Fonction publique" => "s25",
      "Hôtellerie, restauration" => "s26",
      "Immobilier, transactions immobilières" => "s27",
      "Industrie alimentaire" => "s28",
      "Industrie chimique" => "s29",
      "Industrie, ingénierie industrielle" => "s30",
      "Informatique et réseaux" => "s31",
      "Jeu vidéo" => "s32",
      "Journalisme" => "s33",
      "Logistique et transport" => "s34",
      "Maintenance" => "s35",
      "Marketing, publicité" => "s36",
      "Mécanique" => "s37",
      "Métiers d'art" => "s38",
      "Mode" => "s39",
      "Papiers Cartons" => "s40",
      "Paramédical" => "s41",
      "Recherche" => "s42",
      "Santé" => "s43",
      "Sécurité" => "s44",
      "Services postaux" => "s45",
      "Social" => "s46",
      "Sport" => "s47",
      "Tourisme" => "s48",
      "Traduction, interprétation" => "s49",
      "Verre, béton, céramique" => "s50",
    }.map do |sector_name, sector_uuid|
      next if Sector.find_by(name: sector_name)

      Sector.create!(name: sector_name, uuid: sector_uuid)
      print "."
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
    col_hash= { uai: 0, nom_etablissement: 2, adresse: 3, code_postal: 4, commune: 5, position: 6 }
    error_lines = []
    file_location_production = Rails.root.join('db/data_imports/annuaire_lycees.csv')
    file_location_review = Rails.root.join('db/data_imports/annuaire_lycees_light.csv')
    file_location = Rails.env.in?(%w[review development]) ? file_location_review : file_location_production
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
        coordinates: {longitude: longitude, latitude: latitude}
      }
      school = School.new(school_params)
      if school.valid?
        school.save
        print "."
      else
        error_lines << [line_nr , school.name, school.errors.full_messages.join(", ")]
        print "o"
      end
    end
    error_lines.each do |line|
      puts "Error #{line}"
    end
    puts "#{error_lines.size} errors"
    puts "Done with creating schools(lycées)"
  end

  desc 'create operator and user_operator and return api_token'
  task create_operator_and_user: :environment do
    operator_name = ENV['OPERATOR_NAME']
    operator_logo = ENV['OPERATOR_LOGO']
    operator_website = ENV['OPERATOR_WEBSITE']
    [operator_name, operator_logo, operator_website].each {|attr| attr = nil if attr.blank?}
    user_operator_first_name = ENV['OPERATOR_FIRST_NAME']
    user_operator_last_name = ENV['OPERATOR_LAST_NAME']
    user_operator_email = ENV['OPERATOR_EMAIL']
    user_operator_password = ENV['OPERATOR_PASSWORD']

    operator = Operator.find_or_create_by!( name: operator_name ) do |operator|
      operator.logo = operator_logo
      operator.website = operator_website
    end

    user_operator = Users::Operator.find_or_create_by(email: user_operator_email) do |user_operator|
      user_operator.first_name = user_operator_first_name
      user_operator.last_name = user_operator_last_name
      user_operator.email = user_operator_email
      user_operator.password = ENV['OPERATOR_PASSWORD']
      user_operator.accept_terms = true
      user_operator.confirmed_at = Time.now
      user_operator.operator = operator
    end
    puts "Operator and user_operator created"
    puts "Operator api_token: #{user_operator.api_token}"
    puts "---------------------------------"
    puts " "
  end
end