require 'fileutils'
require 'pretty_console.rb'
# usage : rails users:extract_email_data_csv

namespace :offers do
  desc 'Export offers et requests by week'
  task :extract_offers_success_csv, [] => :environment do
    PrettyConsole.say_in_green "Starting extracting offers and applications metadata"

    require 'csv'

    targeted_fields = %i[semaine offres sièges candidatures écoles ratio_offres_ecoles]
    CSV.open("tmp/export_week_activity.csv", "w",force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
      csv << [].concat(targeted_fields, ['environment'])

      InternshipOffer.periods.values.each do |period|
        weekly_framed = InternshipOffers::WeeklyFramed.kept
                                                      .published
                                                      .where(period: period)
        api = InternshipOffers::Api.kept
                                   .published
                                   .where(period: period)
        seats = weekly_framed.pluck(:max_candidates)
        api_seats = api.pluck(:max_candidates)
        # TODO : add applications count
        applications = InternshipApplications::WeeklyFramed.all.count
        offers_count = weekly_framed.count + api.count
        csv << [
                weekly_framed.period_label,
                offers_count,
                seats.sum + api_seats.sum,
                applications.count,
                'production']
      end
    end
    PrettyConsole.say_in_green 'task is finished'
  end

end
