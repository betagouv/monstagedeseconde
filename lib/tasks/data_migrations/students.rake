require 'pretty_console'

namespace :data_migrations do
  desc 'Update students confirmation to ok'
  task confirm_all_students: :environment do |task|
    PrettyConsole.announce_task 'Updating students confirmation to ok' do
      Users::Student.kept.where(confirmed_at: nil).each do |student|
        print '.'
        student.confirmed_at = student.created_at + 1.second
        student.save
      end
      Users::Student.where(confirmed_at: nil).update(confirmed_at: Date.today)
    end
  end

  desc 'get department of north of France'
  task north_data: :environment do |task|
    academy_region_name = 'Hauts-de-France'
    schools_data = []
    omogen = Services::Omogen.new

    departments = AcademyRegion.find_by(name: academy_region_name).departments

    departments.each do |department|
      schools << School.where('LEFT(zipcode, 2) = ?', department.code[0..1])
    end
    schools.flatten!
    # puts schools.map(&:code_uai)
    schools.each do |school|
      sleep 0.3
      data = omogen.sygne_import_by_schools(school.code_uai)&.symbolize_keys
      schools_data << data
      puts "----------------- #{school.code_uai} -----------------"
    end
  end

  desc 'import 3 students only'
  task import_three_students: :environment do |task|
    PrettyConsole.announce_task 'Importing 3 students only' do
      school = School.where(city: 'Lille').first
      schools_data = []
      omogen = Services::Omogen.new
      PrettyConsole.say_in_cyan "Importing students from #{school.name} ##{school.code_uai}  #{school.id}"

      data = omogen.sygne_import_by_schools_little(school.code_uai)&.symbolize_keys
      schools_data << data
      puts "----------------- #{school.code_uai} -----------------"
    end
  end

  desc 'get students of France from omogen and sygne'
  task import_students_data: :environment do |task|
    School.all.find_each(batch_size: 5) do |school|
      ImportDataFromSygneJob.perform_now(school)
      sleep 0.3
    end
  end
end
