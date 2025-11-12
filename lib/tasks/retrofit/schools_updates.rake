require 'csv'
require 'pretty_console'
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

  desc 'college-lycee split fix'
  task fix_college_lycee_split: :environment do
    PrettyConsole.announce_task 'Fixing college-lycee split' do
      counter = 1
      error_lines = []
      ressource_file_location = Rails.root.join('db/data_imports/fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre.csv')
      CSV.foreach(ressource_file_location, 'r', headers: true, header_converters: :symbol, col_sep: ';').each do |row|
        counter += 1
        code_uai = row[:numero_uai]
        school = School.find_by(code_uai: code_uai)
        next if school.nil?

        nature = row[:nature_uai_libe]
        next unless nature.present?

        if nature.downcase.in?(['collège', 'college'])
          next if school.school_type.downcase == 'college'

          school.update!(school_type: 'college')
          PrettyConsole.print_in_yellow '.'
        else
          school.update!(school_type: 'lycee')
          next if school.school_type.downcase == 'lycee'

          PrettyConsole.print_in_blue '.'
        end
      end
    end
  end

  desc 'migrating school_id from school to reserved_schools'
  task :migrate_school_id => :environment do
    PrettyConsole.announce_task 'Switching schools to reserved schools' do
      InternshipOffers::WeeklyFramed.kept.find_each do |offer|
        next if offer.school_id.nil?

        ReservedSchool.find_or_create_by!(
          school_id: offer.school_id,
          internship_offer_id: offer.id
        )
        PrettyConsole.print_in_green '.'
      end
      puts ''
      PrettyConsole.print_in_cyan 'Done with migrating school_id to reserved_schools'
    end
  end

  desc 'create class_room names when missing'
  task create_class_room_names: :environment do
    PrettyConsole.announce_task 'Creating class_room names' do
      counter = 0
      Users::Student.joins(:class_room).kept.where(class_room: {name: nil}).find_each do |student|
        next if student.class_room.nil?

        new_name = case student.grade.short_name
                   when 'seconde'
                     '2de'
                   when 'troisieme'
                     '3ème'
                   when 'quatrieme'
                     '4ème'
                   end

        new_name = "#{new_name} indeterminée"
        next unless student.class_room.name != new_name

        student.class_room.update(name: new_name)
        counter += 1
        PrettyConsole.print_in_green '.'
      end
      puts ''
      PrettyConsole.print_in_cyan "Done with creating #{counter} class_room names"
    end
  end
end
