require 'pretty_console'
def populate_week_reference
  first_year = 2023
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

def populate_month_reference
  next_month = 3.years.ago.beginning_of_month
  loop do
    Month.create!(date: next_month)
    next_month = next_month.next_month
    break if next_month > 10.years.from_now
  end
end

call_method_with_metrics_tracking(%i[
                                    populate_month_reference
                                    populate_week_reference
                                  ])
