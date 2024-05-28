require 'pretty_console'

namespace :retrofit do
  desc 'updating empty strings from students_emails to nil'
  task :removing_empty_id_fields => :environment do |task|
    PrettyConsole.announce_task(task) do
      students = Users::Student.where(email: '')
      students.update_all(email: nil)

      students = Users::Student.where(phone: '')
      students.update_all(phone: nil)
    end
  end
end