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
  task splitting_old_internship_offers: :environment do |task|
    PrettyConsole.announce_task(task) do
      InternshipOffers::WeeklyFramed.kept.each do |offer|
        next if offer.hidden_duplicate
        next if offer.mother_id.present? && offer.splitted?
        next unless offer.has_weeks_after_school_year_start? && offer.has_weeks_before_school_year_start?

        new_internship_offer = offerf.dup

        new_internship_offer.hidden_duplicate = false
        new_internship_offer.mother_id = id
        new_internship_offer.weeks = weeks & Week.weeks_of_school_year(school_year: Week.current_year_start_week.year)
        new_internship_offer.grades = grades
        new_internship_offer.weekly_hours = weekly_hours
        new_internship_offer.save!
        # stats have to exist before intenship_applications is moved
        new_internship_offer.internship_applications = []
        new_internship_offer.save!
        new_internship_offer.publish! unless new_internship_offer.published?

        offer.hidden_duplicate = true
        offer.weeks = weeks & Week.of_past_school_years
        offer.published_at = nil
        offer.aasm_state = 'unpublished'
        save! && new_internship_offer
      end
    end
  end
end
