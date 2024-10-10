require 'pretty_console'

# There's a business gotcha: the given email should NOT be a shared email or a generic one!

namespace :migrations do
  desc 'populate stepper_fields from internship_offers'
  task :populate_stepper_fields, [] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      InternshipOffer.find_each do |internship_offer|
        InternshipOccupation.create!(
          title: internship_offer.title,
          description: internship_offer.description,
          street: internship_offer.street,
          zipcode: internship_offer.zipcode,
          city: internship_offer.city,
          coordinates: internship_offer.coordinates,
          created_at: internship_offer.created_at,
          department: internship_offer.department,
          updated_at: internship_offer.updated_at,
          employer_id: internship_offer.employer_id
          )
          # trades: internship_offer.trades,
      end

      PrettyConsole.say_in_green "Internship occupations populated"

      InternshipOffer.find_each do |internship_offer|
        Entreprise.create!(
          manual_enter: internship_offer.manual_enter,
          siret: internship_offer.siret,
          is_public: internship_offer.is_public,
          employer_name: internship_offer.employer_name,
          chosen_employer_name: internship_offer.employer_name,
          entreprise_city: internship_offer.city,
          entreprise_zipcode: internship_offer.zipcode,
          entreprise_street: internship_offer.street,
          entreprise_coordinates: internship_offer.coordinates,
          tutor_first_name: internship_offer&.tutor&.first_name || '',
          tutor_last_name: internship_offer&.tutor&.last_name || '',
          tutor_email: internship_offer&.tutor&.email || '',
          tutor_phone: internship_offer&.tutor&.phone || '',
          tutor_function: internship_offer&.tutor&.function || ''
        )
      end

      InternshipOffer.find_each do |internship_offer|
        Planning.create!(
          weeks_count: internship_offer.internship_offer_weeks_count,
          max_candidates: internship_offer.max_candidates,
          max_students_per_group: internship_offer.max_students_per_group,
          remaining_seats_count: internship_offer.remaining_seats_count,
          weekly_lunch_break: internship_offer.weekly_lunch_break,
          weekly_hours: internship_offer.weekly_hours,
          daily_hours: internship_offer.daily_hours,
          daily_lunch_break: internship_offer.daily_lunch_break,
          school_id: internship_offer.school_id
        )
      end
    end
  end
end