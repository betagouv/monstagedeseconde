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

  desc 'missing group in internship_offer to be found in organisations'
  task :fixing_missing_group => :environment do |task|
    import 'csv'
    PrettyConsole.announce_task(task) do
      error_lines = []
      file_location = Rails.root.join('storage/tmp/Question_result_2024-06-19_light.csv')
      CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
        next if line_nr.zero?

        cells = row.to_s.split(';')

        offer_id = cells[0]
        offer = InternshipOffer.find_by(id: offer_id)
        next if offer.group_id.present?

        if offer.nil?
          PrettyConsole.puts_in_blue("Skipping offer with id: #{offer_id}")
          next
        end
        if offer.organisation.nil?
          PrettyConsole.puts_in_blue("Missing organisation with offer_id: #{offer_id}")
          next
        end
        group_id = offer.organisation.group_id
        if group_id.nil?
          PrettyConsole.puts_in_blue("Missing group_id with organisation_id: #{organisation.id}")
          next
        end

        offer.update_columns(group_id: group_id)
        print '.'
      end
    end
  end

  task :fixing_missing_group_from_db => :environment do |task|
    PrettyConsole.announce_task(task) do
      InternshipOffers::WeeklyFramed.kept
                                    .where(group_id: nil)
                                    .where(is_public: true)
                                    .each do |offer|
        next if offer.group_id.present?

        if offer.organisation.nil?
          PrettyConsole.puts_in_blue("Missing organisation with offer_id: #{offer_id}")
          next
        end
        group_id = offer.organisation.group_id
        if group_id.nil?
          PrettyConsole.puts_in_blue("Missing group_id with organisation_id: #{organisation.id}")
          next
        end

        offer.update_columns(group_id: group_id)
        print '.'
      end
    end
  end
end
