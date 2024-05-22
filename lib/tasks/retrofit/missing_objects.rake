require 'pretty_console'

def create_organisation_from_internship_offer(offer)
  attributes = {
    employer_name: offer.employer_name,
    employer_website: offer.employer_website,
    coordinates: offer.coordinates,
    street: offer.street,
    zipcode: offer.zipcode,
    city: offer.city,
    is_public: offer.is_public,
    group_id: offer.group_id,
    siret: offer&.siret || '',
    employer_description: offer.employer_description,
    employer_id: offer.employer_id,
    is_paqte: false
  }
  organisation_id = Organisation.find_or_create_by!(attributes).id
  offer.update_columns(organisation_id: organisation_id)
end

namespace :retrofit do
  desc 'missing organisations creation for older kept internship_offers upon internship_offer data'
  task :missing_organisations_creation => :environment do |task|
    PrettyConsole.announce_task(task) do
      ActiveRecord::Base.transaction do
        InternshipOffers::WeeklyFramed.kept
                                      .where(organisation_id: nil)
                                      .each do |offer|
          create_organisation_from_internship_offer(offer)
          print '.'
        end
      end
    end
  end

  desc 'add missing group_id from organisation to internship_offers'
  task :fix_missing_group_id => :environment do |task|
    PrettyConsole.announce_task(task) do
      offers_to_update = InternshipOffers::WeeklyFramed.kept
                                                       .is_public
                                                       .where(group_id: nil)
      PrettyConsole.print_in_yellow("offers to update: #{offers_to_update.count}\n")
      offers_wont_update = offers_to_update.select { |offer| offer.organisation.group_id.nil? }
      PrettyConsole.print_in_cyan("offers that won't update: #{offers_wont_update.count}\n")
      offers_to_update.each do |offer|
        group_id = offer.organisation.group_id
        next if group_id.nil?
        offer.update_columns(group_id: group_id)
        print '.'
      end
    end
  end
end
