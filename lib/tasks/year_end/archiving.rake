require 'pretty_console'
require 'csv'
# year_end_cleaning

namespace :cleaning do
  desc 'archive students and unlink anonymized students from their class room'
  task :archive_students, [] => :environment do |args|
    PrettyConsole.announce_task('Archiving students and unlinking anonymized students from their class room') do
      ActiveRecord::Base.transaction do
        Services::Archiver.archive_students
      end
    end
  end

  desc 'delete all invitations since they might be irrelevant after school year end'
  task :delete_invitations, [] => :environment do |args|
    PrettyConsole.announce_task('Deleting invitations') do
      ActiveRecord::Base.transaction do
        Services::Archiver.delete_invitations
      end
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

  desc "remove url_shrinker's content"
  task :clean_url_shrinker, [] => :environment do |args|
    PrettyConsole.announce_task('Clearing url_shrinker content') do
      UrlShrinker.delete_all
      puts '-- done'
    end
  end

  desc "anonymize and delete what should be after school year's end"
  task year_end: %i[anonymize_internship_agreements
                    archive_students
                    delete_invitations
                    clean_url_shrinker]
end
