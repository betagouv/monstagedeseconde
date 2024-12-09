require 'pretty_console'

namespace :anonymisation do
  desc 'anonymize all students'
  task :students, [] => :environment do |args|
    PrettyConsole.announce_task('Anonymizing students') do
      Services::Archiver.archive_students
    end

    PrettyConsole.announce_task('Anonymizing identities') do
      Services::Archiver.archive_identities
    end
  end

  # internship agreements
  task :internship_agreements, [] => :environment do |args|
    PrettyConsole.announce_task('Anonymizing internship agreements') do
      Services::Archiver.archive_internship_agreements
    end
  end

  desc 'anonymize all internship_agreements'
  task :anonymize_internship_agreements, [] => :environment do |args|
    PrettyConsole.announce_task('Anonymizing internship agreements') do
      ActiveRecord::Base.transaction do
        Services::Archiver.archive_internship_agreements
      end
    end
  end

  # classes
  desc 'anonymize all class_rooms'
  task :class_rooms, [] => :environment do |args|
    PrettyConsole.announce_task('Anonymizing class rooms') do
      Services::Archiver.archive_class_rooms
    end
  end

  desc 'anonymize and delete what should be before merging into 1E1S '
  task all_ms2gt: %i[
    students
    internship_agreements
    class_rooms
  ]
end
