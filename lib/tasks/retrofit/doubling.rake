require 'pretty_console'

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
    # Note : the two scopes private_kept_for_doubling and public_kept_for_doubling are here to exclude
    # offers that cannot be split because of passed records defaults according to new
    # validation criteria.
    # These scopes should be withdrawn when all offers of the passed can be validated "as is"
    PrettyConsole.announce_task(task) do
      InternshipOffer.kept
                     .seconde_and_troisieme
                     .merge(InternshipOffer.private_kept_for_doubling.or(InternshipOffer.public_kept_for_doubling))
                     .find_each do |offer|
        SplitOfferJob.perform_now(internship_offer_id: offer.id)
        print "-"
      end
    end
  end

  desc 'doubling offer test when associated to several grades'
  task doubling_offers_test: :environment do |task|
    PrettyConsole.announce_task(task) do
      counter = 0
      total_offer_counted = 0
      InternshipOffer.kept
                     .seconde_and_troisieme
                     .merge(InternshipOffer.private_kept_for_doubling.or(InternshipOffer.public_kept_for_doubling))
                     .find_each do |offer|
        total_offer_counted += 1
        weeks_seconde = offer.weeks.select { |week| week.number >= 24 && week.number <= 27}
        weeks_troisieme_quatrieme = offer.weeks.to_a - weeks_seconde.to_a
        if weeks_seconde.empty? || weeks_troisieme_quatrieme.empty?
          counter += 1
        end
      end
      PrettyConsole.say_in_green("Tested #{counter} offers cannot be split out of #{total_offer_counted} offers counted")
    end
  end
end
