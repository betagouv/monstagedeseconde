require 'pretty_console'
namespace :migrations do
  desc 'add_weeks'
  task :add_weeks, [] => :environment do |t, args|
    first_year = 2025
    last_year = Time.now.year + 2

    first_week = 1
    max_weeks = 53

    first_year.upto(last_year) do |year|
      PrettyConsole.say_in_yellow("year: #{year} - adding weeks...")
      # Determine the number of weeks in the year (52 or 53) safely
      weeks_in_year = begin
        Date.commercial(year, max_weeks, 1)
        53
      rescue Date::Error
        52
      end

      first_week.upto(weeks_in_year) do |week|
        Week.find_or_create_by(year: year, number: week)
        print('.')
      rescue ActiveRecord::RecordNotUnique
        puts "week #{week} - #{year} already exists"
      end
    end
    PrettyConsole.say_in_blue('done with weeks adding')
  end
end
