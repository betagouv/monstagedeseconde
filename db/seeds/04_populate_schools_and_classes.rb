import 'csv'
require 'pretty_console'
def populate_schools
  # Lycées
  col_hash = { uai: 0, nom_etablissement: 2, adresse: 3, code_postal: 4, commune: 5, position: 6 }
  error_lines = []
  file_location_production = Rails.root.join('db/data_imports/annuaire_lycees.csv')
  file_location_review = Rails.root.join('db/data_imports/light_files/annuaire_lycees_light.csv')
  file_location = Rails.env.in?(%w[review development]) ? file_location_review : file_location_production
  CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
    next if line_nr.zero?

    cells = row.to_s.split(';')
    cells[6] = cells[6].split(',').reverse.join(',') if cells[6].present? # reverse to match longitude, latitude order

    uai = cells[col_hash[:uai]]
    next if uai.nil?
    next if School.find_by(code_uai: uai)

    params = school_params(col_hash:, cells:).merge!({ school_type: :lycee })
    params.merge!({ qpv: true }) if line_nr % 10 == 0
    params.merge!({ rep_kind: 'rep' }) if line_nr % 7 == 0
    params.merge!({ rep_kind: 'rep_plus' }) if line_nr % 17 == 0

    school = School.new(params)
    if school.valid?
      school.save
      print '.'
    else
      error_lines << ["ligne: #{line_nr}", school.name, school.errors.full_messages.join(', ')]
      print 'o'
    end
  end
  error_lines.each do |line|
    puts "Error #{line} | "
  end
  puts "#{error_lines.size} errors"
  puts 'Done with creating schools(lycées)'
  # ---------------------
  # Collèges
  puts '---------------------'
  puts 'collèges '
  file_location_production = Rails.root.join('db/data_imports/seed-colleges.csv')
  file_location_review = Rails.root.join('db/data_imports/light_files/seed-colleges-light.csv')
  file_location = Rails.env.in?(%w[review development]) ? file_location_review : file_location_production
  CSV.foreach(file_location, headers: { col_sep: ',' }).each.with_index do |row, i|
    next if i.zero?

    name = row['ETABLISSEMENT'].gsub('Collège ', '').gsub('College ', '')
    school = School.find_or_create_by!(
      code_uai: row['Code UAI'],
      name: "Collège #{name}",
      city: row['Commune'],
      department: Department.fetch_by_zipcode(zipcode: row['zipcode']),
      zipcode: row['zipcode'],
      coordinates: geo_point_factory_array(JSON.parse(row['coordinates'])['coordinates'])
    )
    print '-'
    school.update(qpv: true) if i % 10 == 0
    school.update(rep_kind: 'rep') if i % 7 == 0
    school.update(rep_kind: 'rep_plus') if i % 17 == 0
  end
  puts ''
  puts 'Done with creating schools(collèges)'
end

def school_params(col_hash:, cells:)
  uai = cells[col_hash[:uai]]
  nom_etablissement = cells[col_hash[:nom_etablissement]]
  adresse = cells[col_hash[:adresse]]
  code_postal = cells[col_hash[:code_postal]].to_i.to_s
  code_postal = "0#{code_postal}" if code_postal.size == 4
  commune = cells[col_hash[:commune]]
  position_array = cells[col_hash[:position]].split(',').map(&:to_f)
  longitude = position_array[0]
  latitude = position_array[1]
  if (longitude == 0.0 && latitude == 0.0) || (longitude.nil? || latitude.nil?)
    full_address = "#{adresse}, #{code_postal} #{commune}"
    coordinates = Geofinder.coordinates(full_address)
    puts ''
    longitude = coordinates[0]
    latitude = coordinates[1]
  end
  {
    code_uai: uai,
    name: nom_etablissement,
    street: adresse,
    zipcode: code_postal,
    city: commune,
    school_type: :college,
    department: Department.fetch_by_zipcode(zipcode: code_postal),
    coordinates: { longitude:, latitude: }
  }
end

def populate_class_rooms
  col_hash = { academie: 0, code_uai: 1, 'id_etab_sco-net': 2, class_room_name: 3, class_size: 4 }
  error_lines = []
  file_location = Rails.root.join('db/data_imports/noms_de_classes.csv')
  CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
    # with_index(2) : 2 is the offset to keep track of line number, taking into account the header
    next if line_nr.zero?

    cells = row.to_s.split(';')

    code_uai = cells[col_hash[:code_uai]]
    school = School.find_by(code_uai:)
    unless school.nil?
      print "#{school.name} - #{school.code_uai} missing data" if cells[col_hash[:class_room_name]].blank?
      class_room_name_new = false
      class_room = ClassRoom.find_or_create_by(name: cells[col_hash[:class_room_name]], school:) do |class_room|
        class_room.class_size = cells[col_hash[:class_size]]
        class_room.name = cells[col_hash[:class_room_name]]
        class_room.school_id = school.id
        class_room_name_new = true
      end
    end
  end
  puts ''
  PrettyConsole.say_in_yellow 'Done with creating class_rooms'
  ClassRoom.find_or_create_by(name: '3e A', school: a_parisian_college, grade: Grade.troisieme)
end

def update_schools_with_public_private_info
  col_hash = { uai: 0, public_private: 1, contract_label: 2, contract_code: 3 }
  error_lines = []
  file_location = Rails.root.join('db/data_imports/school_public_prive.csv')
  CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
    next if line_nr.zero?

    cells = row.to_s.split(';')

    uai = cells[col_hash[:uai]]
    next if uai.nil?

    school = School.find_by(code_uai: uai)
    next if school.nil?

    is_public = cells[col_hash[:public_private]].gsub("\n", '') == 'Public'
    contract_code = cells[col_hash[:contract_code]].gsub("\n", '')

    school_params = {
      is_public:,
      contract_code:
    }

    result = school.update(**school_params)
    if result
      print '.'
    else
      error_lines << ["Ligne #{line_nr}", school.name, school.errors.full_messages.join(', ')]
      print 'o'
    end
  end
  puts ''
  PrettyConsole.say_in_yellow 'Done with updating schools(lycées)'
end

def a_parisian_lycee(school_type = :lycee)
  # code_uai: "0753268V"
  # school at Paris, Lycée polyvalent Jean Lurçat - Site Gobelins;48 avenue des Gobelins
  School.where(school_type:, city: 'Paris').first
end

# used for application
# def populate_school_weeks
#   school = a_parisian_lycee

#   # used to test matching between internship_offers.weeks and existing school_weeks
#   other_schools = School.nearby(latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude],
#                                 radius: 60_000).limit(4)
#                         .where.not(id: school.id)
# end

# Troisiemes

def populate_class_rooms_3eme
  school = a_parisian_college

  ClassRoom.create(name: '3e A', school:)
  ClassRoom.create(name: '3e B', school:)
  ClassRoom.create(name: '3e C', school:)
end

def missing_school_manager_school
  School.find_by_code_uai('0755030K') # school at Paris, school name : collège Daniel Mayer.
end

def populate_school_weeks(type = :lycee)
  weeks =  if type == :college
                   Week.troisieme_selectable_weeks.first(2) + Week.troisieme_selectable_weeks.first(24).last(2)
                 else # :lycee
                   Week.seconde_selectable_weeks
                 end
  school = a_parisian_lycee(type)
  school.weeks = weeks
  school.save!

  return if type == :lycee

  # Troisiemes
  # used to test matching between internship_offers.weeks and existing school_weeks
  other_schools = School.nearby(latitude: Coordinates.paris[:latitude],
                                longitude: Coordinates.paris[:longitude],
                                radius: 60_000)
                        .where.not(id: school.id)
                        .where(school_type: type)
                        .limit(4)
  other_schools.each.with_index do |another_school, i|
    another_school.update!(weeks: Week.troisieme_selectable_weeks.limit(i + 1))
  end
  missing_school_manager_school.update!(weeks: weeks)
end

call_method_with_metrics_tracking([
                                    :populate_schools,
                                    :populate_class_rooms,
                                    %i[populate_school_weeks lycee],
                                    :update_schools_with_public_private_info,
                                    :populate_class_rooms_3eme,
                                    %i[populate_school_weeks college]
                                  ])
