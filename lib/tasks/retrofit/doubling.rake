require 'pretty_console'

namespace :retrofit do
  desc 'doubling offer when associated to several grades'
  task doubling_offers: :environment do |task|
    PrettyConsole.announce_task(task) do
      InternshipOffer.find_each do |offer|
        grades = offer.grades.to_a.dup
        next if grades.size <= 1

        PrettyConsole.say_in_yellow("InternshipOffer ID: #{offer.id} is associated to multiple grades: #{grades.map(&:name).join(', ')}")

        if grades.include?(Grade.seconde)
          weeks_troisieme_quatrieme = offer.weeks & Week.troisieme_weeks
          
          message = "Unexpected error: No weeks for troisieme/quatrieme found in ##{offer.id}"
          if weeks_troisieme_quatrieme.nil?
            PrettyConsole.say_in_red(message)
            raise message
          end
          next if weeks_troisieme_quatrieme.empty?

          weeks_seconde = offer.weeks & Week.seconde_weeks
          message = "Unexpected error: No weeks for seconde found in ##{offer.id}"
          if weeks_seconde.nil?
            PrettyConsole.say_in_red(message)
            raise message
          end
          next if weeks_seconde.empty?

          seconde_favorites = Favorite.joins(:user)
                                      .where(internship_offer_id: offer.id)
                                      .where(user: { grade_id: Grade.seconde.id })
          troisieme_favorites_user_ids = Favorite.joins(:user)
                                                 .where(internship_offer_id: offer.id)
                                                 .where(user: { grade_id: Grade.troisieme_et_quatrieme.ids })
                                                 .pluck(:user_id)


          stats = offer.stats
          schools_seconde = offer.schools.select do |school|
            school.school_type == 'lycee' ||  school.school_type == 'college_lycee'
          end
          school_troisieme_quatrieme = offer.schools.select do |school|
            school.school_type == 'college'  ||  school.school_type == 'college_lycee'
          end

          # duplication
          new_offer = offer.dup
          seconde_offer = offer

          # some restrictions
          seconde_offer.grades = [Grade.seconde]
          seconde_offer.weeks = weeks_seconde
          seconde_offer.mother_id = nil
          seconde_offer.favorites = seconde_favorites
          seconde_offer.save!

          next if weeks_troisieme_quatrieme.empty?

          new_offer.grades = grades.to_a - [Grade.seconde]
          new_offer.weeks = weeks_troisieme_quatrieme
          new_offer.mother_id = offer.id
          new_offer.internship_applications = offer.internship_applications
          new_offer.created_at = offer.created_at
          new_offer.updated_at = offer.updated_at
          new_offer.from_doubling_task = true
          if new_offer.valid? && new_offer.from_doubling_task_save!
            PrettyConsole.say_in_green("Created new InternshipOffer ID: #{new_offer.id} for grade: #{new_offer.grades.map(&:name).join(', ')}")
          else
            error_message = "Failed to create new InternshipOffer for grade: #{new_offer.grades.map(&:name).join(', ')}. Errors: #{new_offer.errors.full_messages.join(', ')}"
            PrettyConsole.say_in_red(error_message)
          end

          # reassign favorites
          unless troisieme_favorites_user_ids.empty?
            troisieme_favorites_user_ids.each do |user_id|
              Favorite.create(internship_offer: new_offer, user_id: user_id)
            end
          end

          # reassign applications
          every_applications = seconde_offer.internship_applications.to_a
          unless every_applications.empty?
            applications_for_seconde = every_applications.select { |application| application.student.grade == Grade.seconde }.to_a
            applications_for_troisieme_quatrieme = every_applications - applications_for_seconde

            applications_for_seconde.each do |application|
              application.update!(internship_offer_id: seconde_offer.id)
            end
            unless applications_for_troisieme_quatrieme.empty?
              applications_for_troisieme_quatrieme.each do |application|
                application.update!(internship_offer_id: new_offer.id)
              end
            end
          end

          # reassign inappropriate_offer not done as it's not used yet

          # reassign users_internship_offers_histories
          UsersInternshipOffersHistory.where(internship_offer_id: offer.id).find_each do |history|
            if history.user.grade == Grade.seconde
              history.update!(internship_offer_id: seconde_offer.id)
            else
              history.update!(internship_offer_id: new_offer.id)
            end
          end

          # reassign reserved_schools
          offer.schools = []
          seconde_offer.schools = schools_seconde
          new_offer.schools = school_troisieme_quatrieme
        end
      end
    end
  end
end
