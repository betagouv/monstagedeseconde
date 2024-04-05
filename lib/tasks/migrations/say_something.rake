require 'pretty_console'
namespace :migrations do
  desc 'test task'
  task :say_something, [:argument] => :environment do |t, args|
    3.times{ print '.'; sleep 0.5}
    puts 'Done'
    PrettyConsole.say_in_green(args.argument)
  end

  desc 'Fullfill schools department'
  task :fullfill_schools_department => :environment do
    School.all.each do |school|
      school.update(department_id: Department.find_by(name: school.department).id)
    end 
  end

end