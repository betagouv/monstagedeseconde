require 'pretty_console'

namespace :retrofit do
  desc 'removing internship_agreements for those students without school (but keep the internship_applications)'
  task :removing_extra_agreements => :environment do |task|
    PrettyConsole.announce_task(task) do
      students = Users::Student.where(school_id: nil)
      PrettyConsole.say_in_yellow "Removing internship_agreements for #{students.count} students without school..."
      PrettyConsole.puts_in_cyan students.map(&:email).join("\n")
      students.each do |student|
        student.internship_applications.map(&:internship_agreement).compact.each do |ia| 
          ia.destroy 
        end
      end
    end
  end
end
