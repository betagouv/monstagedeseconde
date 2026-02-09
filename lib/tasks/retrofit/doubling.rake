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
    PrettyConsole.announce_task(task) do
      InternshipOffer.kept.seconde_and_troisieme.find_each do |offer|
        SplitOfferJob.perform_now(internship_offer_id: offer.id)
        print "-"
      end
    end
  end
end
