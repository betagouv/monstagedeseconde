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

  desc 'import students with sygne from a region'
  task :region_data, [:academy_region_name] => :environment do |task, args|
    # invoke as : rake "data_migrations:region_data[Normandie]"
    schools_data = []
    schools = []
    omogen = Services::Omogen::Sygne.new
    departments = AcademyRegion.find_by(name: args.academy_region_name).departments
    departments.each do |department|
      schools << School.where('LEFT(zipcode, 2) = ?', department.code[0..1])
    end
    schools.flatten!
    # puts schools.map(&:code_uai)
    counter = 0
    schools.each do |school|
      counter += 1
      data = omogen.sygne_import_by_schools(school.code_uai)&.symbolize_keys
      schools_data << data
      puts "----------------- #{school.code_uai} -----------------"
    end
    puts "----------------- #{counter} écoles importées -----------------"
  end

  desc 'import students with sygne from a department'
  task :department_data, %i[department_name] => :environment do |task, args|
    # invoke as : rake "data_migrations:department_data[Loiret]"
    department_name = args.department_name
    PrettyConsole.announce_task "Importing #{department_name}'s schools" do
      schools_data = []
      omogen = Services::Omogen::Sygne.new
      department = Department.find_by(name: department_name)

      schools = School.where('LEFT(zipcode, 2) = ?', department.code[0..1]).to_a
      counter = 0
      schools.each do |school|
        data = omogen.sygne_import_by_schools(school.code_uai)&.symbolize_keys
        schools_data << data
        puts "----------------- #{school.code_uai} -----------------"
        counter += 1
      end
      PrettyConsole.say_in_cyan "Imported #{counter} schools"
    end
  end

  desc 'import 3 students only'
  task import_three_students: :environment do |task|
    PrettyConsole.announce_task 'Importing 3 students only' do
      school = School.where(city: 'Lille').first
      schools_data = []
      omogen = Services::Omogen::Sygne.new
      PrettyConsole.say_in_cyan "Importing students from #{school.name} uai:#{school.code_uai}  ##{school.id}"

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
