import 'csv'
def populate_schools
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
      full_address = "#{adresse}, #{code_postal} #{commune}"
      coordinates = Geofinder.coordinates(full_address)
      puts ''
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
      error_lines << ["ligne: #{line_nr}" , school.name, school.errors.full_messages.join(", ")]
      print "o"
    end
  end
  error_lines.each do |line|
    puts "Error #{line} | "
  end
  puts "#{error_lines.size} errors"
  puts "Done with creating schools(lycées)"
end

def populate_class_rooms
  school = find_default_school_during_test

  ClassRoom.create(name: '2de A', school: school)
  ClassRoom.create(name: '2de B', school: school)
  ClassRoom.create(name: '2de C', school: school)
end

def find_default_school_during_test
  # school at Paris, Lycée polyvalent Jean Lurçat - Site Gobelins;48 avenue des Gobelins
  School.find_by_code_uai("0753268V")
end

def missing_school_manager_school
  # school at Paris (Lavoisier)
  School.find_by_code_uai("0750656F")
end

# used for application
def populate_school_weeks
  school = find_default_school_during_test
  weeks = Week.where(year: SchoolYear::Current.new.end_of_period.year.to_i, number: [29, 30])
  # used for application
  school.weeks = weeks
  school.save!

  # used to test matching between internship_offers.weeks and existing school_weeks
  other_schools = School.nearby(latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude], radius: 60_000).limit(4)
                        .where.not(id: school.id)
  other_schools.each.with_index do |another_school, i|
    another_school.update!(weeks: weeks)
  end
  missing_school_manager_school.update!(weeks: weeks)
end

call_method_with_metrics_tracking([
  :populate_schools,
  :populate_class_rooms,
  :populate_school_weeks
])