# frozen_string_literal: true

#
require 'pretty_console'

namespace :checks do
  desc 'check if each weekly offers have week'
  task offers_have_weeks: :environment do
    PrettyConsole.announce_task('check if each weekly offers have week') do
      counter = 0
      InternshipOffers::WeeklyFramed.kept.each do |offer|
        next unless offer.weeks.empty? || offer.grades.empty?

        counter += 1
        # puts "Weekly offer #{offer.id} has no weeks created #{offer.created_at.strftime('%d/%m/%Y')}"
        # ad a line with id in the csv in storage/weekly_offers_without_weeks.csv
        CSV.open('storage/weekly_offers_without_weeks.csv', 'a') do |csv|
          csv << [offer.id, offer.created_at.strftime('%d/%m/%Y'), offer.grades.map(&:name).join('|'), offer.school_id]
        end
      end
      puts '================================'
      puts "counter : #{counter}"
      puts '================================'
      puts ''
    end
  end
end
