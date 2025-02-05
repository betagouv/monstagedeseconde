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
    PrettyConsole.announce_task "Importing #{args.academy_region_name}'s schools" do
      # invoke as : rake "data_migrations:region_data[Normandie]"
      # schools_data = []
      schools = []
      # omogen = Services::Omogen::Sygne.new
      departments = AcademyRegion.find_by(name: args.academy_region_name).departments
      departments.each do |department|
        schools << School.where('LEFT(zipcode, 2) = ?', department.code[0..1])
      end
      schools.flatten!
      # puts schools.map(&:code_uai)
      counter = 0
      schools.each do |school|
        next if school.full_imported

        counter += 1
        ImportDataFromSygneJob.perform_later(school)
        puts "----------------- #{school.code_uai} -----------------"
      end
      puts "----------------- #{counter} écoles importées -----------------"
    end
  end

  desc 'import students with sygne from a department'
  task :department_data, %i[department_name] => :environment do |task, args|
    # invoke as : rake "data_migrations:department_data[Loiret]"
    department_name = args.department_name
    PrettyConsole.announce_task "Importing #{department_name}'s schools" do
      department = Department.find_by(name: department_name)
      schools = School.where('LEFT(zipcode, 2) = ?', department.code[0..1]).to_a
      counter = 0
      schools.each do |school|
        next if school.full_imported

        ImportDataFromSygneJob.perform_later(school)
        puts "----------------- #{school.code_uai} -----------------"
        counter += 1
      end
      PrettyConsole.say_in_cyan "Imported #{counter} schools"
    end
  end

  desc 'import a school'
  task import_school: :environment do |task|
    PrettyConsole.announce_task 'Importing lycée Pasteur' do
      school = School.where(city: 'Lille').third
      PrettyConsole.say_in_cyan "Importing students from #{school.name} uai:#{school.code_uai}  ##{school.id}"
      ImportDataFromSygneJob.perform_later(school)
      puts "----------------- #{school.code_uai} -----------------"
      school.update(full_imported: true)
    end
  end

  desc 'import 3 students only'
  task import_three_students: :environment do |task|
    PrettyConsole.announce_task 'Importing 3 students only' do
      school = School.where(city: 'Lille').first
      omogen = Services::Omogen::Sygne.new
      PrettyConsole.say_in_cyan "Importing students from #{school.name} uai:#{school.code_uai}  ##{school.id}"

      omogen.sygne_import_by_schools_little(school.code_uai)
      puts "----------------- #{school.code_uai} -----------------"
    end
  end

  desc 'get students of France from omogen and sygne'
  task import_students_data: :environment do |task|
    School.all.find_each(batch_size: 5) do |school|
      next if school.full_imported

      ImportDataFromSygneJob.perform_later(school)
      sleep 0.3
    end
  end

  desc 'update full_imported schools a posteriori from students import'
  task update_full_imported_schools: :environment do |task|
    counter = 0
    Users::Student.kept
                  .joins(:school)
                  .select('DISTINCT school_id')
                  .map { |obj| obj.school_id }
                  .uniq
                  .each do |school_id|
      school = School.find(school_id)
      next if school.nil?

      counter += 1
      school.update(full_imported: true)
    end
    PrettyConsole.say_in_cyan "Updated #{counter} schools"
  end

  desc 'double ine students delete'
  task double_ine_delete: :environment do |task|
    PrettyConsole.announce_task 'Deleting double ine students' do
      counter = 0
      Users::Student.group(:ine)
                    .having('count(ine) > 1')
                    .pluck(:ine)
                    .each do |ine|
        students = Users::Student.kept.where(ine: ine)
        students.first.delete
        print '.'
      end
       PrettyConsole.say_in_cyan "Deleted #{counter} students"
    end
  end

  desc 'get doublon of values in a table on ine column'
  task :doublon, [] => :environment do |t, args|
    PrettyConsole.announce_task "Looking for doublon in users" do
      sql = "SELECT ine, COUNT(ine) FROM users GROUP BY ine HAVING COUNT(ine) > 1"
      result = ActiveRecord::Base.connection.execute(sql)
      puts "Found #{result.count} doublons"
      result.each do |row|
        puts row.to_s
      end
    end
  end
end
