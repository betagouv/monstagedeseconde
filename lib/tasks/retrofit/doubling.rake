require 'pretty_console'

def reserved_schools(offer)
  schools_seconde = offer.schools.select do |school|
    school.school_type == 'lycee' || school.school_type == 'college_lycee'
  end
  schools_troisieme_quatrieme = offer.schools.select do |school|
    school.school_type == 'college' || school.school_type == 'college_lycee'
  end
  {schools_seconde:, schools_troisieme_quatrieme:}
end

def duplicate_history(seconde_offer)
  histories = UsersInternshipOffersHistory.where(internship_offer_id: seconde_offer.id)
  histories.find_each do |history|
    views = history.views
    clicks = history.clicks
    UsersInternshipOffersHistory.create(
      user_id: history.user_id,
      internship_offer_id: new_offer.id,
      views: views,
      clicks: clicks,
      created_at: history.created_at,
      updated_at: history.updated_at
    )
    print '.'
  end
end

# to be duplicated/separated according to cases
# - schools as reserved schools (separated by school_type)
# - favorites (reassigned to new offers according to user grade)
# - internship applications (reassigned to new offers according to student grade)
# - users_internship_offers_histories (reassigned to new offers, plaing duplication)
# - weeks (restricted to the grade)

# aasm_state is duplicated as is and not changed
# max_candidates follow along
# unpublishing with cron job works as is : it does not publish whatever offer


namespace :retrofit do
  desc 'doubling offer when associated to several grades'
  task doubling_offers: :environment do |task|
    PrettyConsole.announce_task(task) do
      InternshipOffer.find_each do |offer|
        print "."
        grades = offer.grades.to_a.dup
        next if grades.size <= 1
        print "-"

        # split logic starts here
        stats = offer.stats
        offer_year = offer.weeks.last.year
        weeks_seconde = offer.weeks.select { |week| week.year == offer_year && week.number > 24 && week.number < 27}
        weeks_troisieme_quatrieme = offer.weeks.reject { |week| week.year == offer_year && week.number > 24 && week.number < 27}
        seconde_favorites_user_ids = Favorite.joins(:user)
                                    .where(internship_offer_id: offer.id)
                                    .where(user: { grade_id: Grade.seconde.id, discarded_at: nil })
                                    .pluck(:user_id)
        troisieme_favorites_user_ids = Favorite.joins(:user)
                                               .where(internship_offer_id: offer.id)
                                               .where(user: { grade_id: Grade.troisieme_et_quatrieme.ids, discarded_at: nil })
                                               .pluck(:user_id)
        applications_for_troisieme_quatrieme = InternshipApplication.joins(:student)
                                                                    .where(internship_offer_id: offer.id)
                                                                    .where(student: { grade_id: Grade.troisieme_et_quatrieme.ids, discarded_at: nil })
        applications_for_seconde = InternshipApplication.joins(:student)
                                                        .where(internship_offer_id: offer.id)
                                                        .where(student: { grade_id: Grade.seconde.id, discarded_at: nil })
        res_schools = reserved_schools(offer)
        if offer.from_api?
          PrettyConsole.say_in_yellow("InternshipOffer ID: #{offer.id} is from API it reduces grades to \"seconde\" only.")
          offer.grades = [Grade.seconde]
          # No change on internship applications as from_api offers don't have any
          # no change on history, just keep it as is
          offer.schools = res_schools[:schools_seconde]
          offer.favorites = Favorite.where(user_id: seconde_favorites_user_ids, internship_offer_id: offer.id)
          offer.weeks = weeks_seconde
          offer.save!
        else # weekly framed , multi offers
          PrettyConsole.say_in_yellow("InternshipOffer ID: #{offer.id} is associated to multiple grades: #{grades.map(&:name).join(', ')}")

          if grades.include?(Grade.seconde)
            # weeks separation

            message = "Unexpected error: No weeks for troisieme/quatrieme found in ##{offer.id}"
            if weeks_troisieme_quatrieme.empty?
              PrettyConsole.say_in_red(message)
              raise message
            end

            message = "Unexpected error: No weeks for seconde found in ##{offer.id}"
            if weeks_seconde.empty?
              PrettyConsole.say_in_red(message)
              raise message
            end
            # --- weeks separation done

            # duplication
            new_offer = offer.dup
            seconde_offer = offer

            # some restrictions on original offer
            seconde_offer.grades = [Grade.seconde]
            seconde_offer.weeks = weeks_seconde
            seconde_offer.mother_id = nil
            Favorite.where(user_id: seconde_favorites_user_ids, internship_offer_id: offer.id)
                    .update_all(internship_offer_id: seconde_offer.id)
            # seconde_offer.favorites = Favorite.where(user_id: seconde_favorites_user_ids, internship_offer_id: offer.id)
            seconde_offer.favorites.reload
            seconde_offer.schools = res_schools[:schools_seconde]
            seconde_offer.reload.save!

            next if weeks_troisieme_quatrieme.empty?

            new_offer.grades = grades.to_a - [Grade.seconde]
            new_offer.weeks = weeks_troisieme_quatrieme
            new_offer.mother_id = offer.id
            new_offer.created_at = offer.created_at
            new_offer.updated_at = offer.updated_at
            new_offer.from_doubling_task = true
            if new_offer.valid? && new_offer.from_doubling_task_save!
              print "-"
            else
              error_message = "Failed to create new InternshipOffer for grade: #{new_offer.grades.map(&:name).join(', ')}. Errors: #{new_offer.errors.full_messages.join(', ')}"
              PrettyConsole.say_in_red(error_message)
            end

            # reassign favorites when students exist or when offer still is valid 
            unless troisieme_favorites_user_ids.empty? || new_offer.last_date < Date.today
              Favorite.where(user_id: troisieme_favorites_user_ids, internship_offer_id: offer.id)
                      .update_all(internship_offer_id: new_offer.id)
            end
            new_offer.save!

            # reassign applications - order matters here
            unless applications_for_seconde.empty? && applications_for_troisieme_quatrieme.empty?
              unless applications_for_troisieme_quatrieme.empty?
                applications_for_troisieme_quatrieme.each do |application|
                  application.update!(internship_offer_id: new_offer.id)
                end
              end
              unless applications_for_seconde.empty?
                applications_for_seconde.each do |application|
                  application.update!(internship_offer_id: seconde_offer.id)
                end
              end
            end

            # reassign inappropriate_offer is not in the scope here

            # reassign users_internship_offers_histories
            duplicate_history(seconde_offer)

            # reassign reserved_schools
            new_offer.schools = res_schools[:schools_troisieme_quatrieme]
            # save the associations
            new_offer.save!
            seconde_offer.save!
          end
        end
      end
    end
  end
end
