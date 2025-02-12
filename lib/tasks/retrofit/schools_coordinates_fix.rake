namespace :retrofit do
  desc 'fix localisation of schools'
  task fix_schools_coordinates: :environment do
    counter = 1
    error_lines = []
    ressource_file_location = Rails.root.join('db/data_imports/fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre.csv')
    CSV.foreach(ressource_file_location, 'r', headers: true, header_converters: :symbol, col_sep: ';').each do |row|
      counter += 1
      code_uai = row[:numero_uai]
      school = School.find_by(code_uai: code_uai)
      next if school.nil?

      longitude = 0.0
      latitude = 0.0
      csv_position = row[:position]
      if csv_position.present?
        coordinates = csv_position.split(',').map(&:to_f)
        longitude = coordinates[1]
        latitude = coordinates[0]
        school.coordinates = { longitude: longitude, latitude: latitude }
        puts school.errors.full_messages unless school.valid?
        school.update(coordinates: { longitude: longitude, latitude: latitude })
        print '.'
      end
      next unless longitude == 0.0 || latitude == 0.0

      error = "Ligne #{counter}, #{school.name}, #{school.street}, #{school.zipcode} #{school.city}: no coordinates found"
      puts error
      error_lines << error
      next
    end
    puts "#{error_lines.size} errors"
    puts error_lines
    PrettyConsole.say_in_yellow 'Done with creating schools(lycées)'
  end
end
