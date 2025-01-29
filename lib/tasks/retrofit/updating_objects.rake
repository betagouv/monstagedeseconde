require 'pretty_console'

namespace :retrofit do
  desc 'updating empty strings from students_emails to nil'
  task removing_empty_id_fields: :environment do |task|
    PrettyConsole.announce_task(task) do
      students = Users::Student.where(email: '')
      students.update_all(email: nil)

      students = Users::Student.where(phone: '')
      students.update_all(phone: nil)
    end
  end

  desc 'split older offers when they have weeks in the past and in the future'
  task split_old_internship_offers: :environment do |task|
    PrettyConsole.announce_task(task) do
      counter = 0
      counter_dup = 0
      InternshipOffers::WeeklyFramed.kept
                                    .where(hidden_duplicate: false)
                                    .each do |offer|
        counter += 1
        next unless offer.has_weeks_after_school_year_start? && offer.has_weeks_before_school_year_start?

        new_internship_offer = offer.dup
        print "."
        counter_dup += 1

        new_internship_offer.hidden_duplicate = false
        new_internship_offer.mother_id = offer.id
        new_internship_offer.weeks = offer.weeks & Week.weeks_of_school_year(school_year: Week.current_year_start_week.year)
        new_internship_offer.grades = offer.grades
        new_internship_offer.weekly_hours = offer.weekly_hours
        new_internship_offer.save!
        # stats have to exist before intenship_applications is moved
        new_internship_offer.internship_applications = []
        new_internship_offer.save!
        new_internship_offer.publish! unless new_internship_offer.published?

        offer.hidden_duplicate = true
        offer.weeks = offer.weeks & Week.of_past_school_years
        offer.published_at = nil
        offer.aasm_state = 'unpublished'
        offer.save!
      end
      puts "#{counter_dup} offers have been duplicated"
      PrettyConsole.say_in_green "#{counter} offers have been processed"
    end
  end
end
