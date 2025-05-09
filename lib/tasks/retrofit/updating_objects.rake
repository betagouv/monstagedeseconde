require 'pretty_console'
require 'csv'

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
        print '.'
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

  desc "17/02/2025 - update applications related to seconde's internship offers set on two weeks"
  task set_two_weeks_according_to_offer: :environment do |task|
    PrettyConsole.announce_task(task) do
      counter = 0
      limit_week_id = 337
      offer_ids = InternshipOffers::WeeklyFramed.kept
                                                .shown_to_employer
                                                .joins(:weeks, :internship_applications)
                                                .where('weeks.id > ?', limit_week_id)
                                                .group('internship_offers.id')
                                                .having('count(weeks.id) = 2')
                                                .count
                                                .keys
      puts offer_ids.count
      puts offer_ids[counter] if counter % 50 == 0
      puts '----------'

      # search for internship_applications related to offer_ids that have only one week related
      InternshipApplication.joins(:weekly_internship_offer, :weeks)
                           .where(internship_offer_id: offer_ids)
                           .where('weeks.id > ?', limit_week_id)
                           .group('internship_applications.id')
                           .having('count(weeks.id) = 1')
                           .pluck(:id)
                           .each do |application_id|
        puts application_id if counter % 30 == 0
        application = InternshipApplication.find_by(id: application_id)
        if application.nil?
          PrettyConsole.say_in_red "application_id: #{application_id} not found"
          next
        end
        application.weeks = SchoolTrack::Seconde.both_weeks
        counter += 1
        puts application.id if counter % 50 == 0
      end
      PrettyConsole.say_in_green "#{counter} applications have been processed"
    end
  end

  desc '10/04/2025 - update offers of private entreprises with non null group_id'
  task nullify_group_id: :environment do |task|
    PrettyConsole.announce_task(task) do
      counter = 0
      InternshipOffers::WeeklyFramed.where(is_public: false)
                                    .where.not(group_id: nil)
                                    .each do |internship_offer|
        internship_offer.update_columns(group_id: nil)
        counter += 1
      end
      PrettyConsole.say_in_green "#{counter} offers have been processed"
      # ***********************************
      counter = 0
      Entreprise.where(is_public: false)
                .where.not(group_id: nil)
                .each do |entreprise|
        entreprise.update_columns(group_id: nil)
        counter += 1
      end
      PrettyConsole.say_in_green "#{counter} entreprises have been processed"
    end
  end

  desc '24/04/2025 - update offers from public offers without group_id'
  task :set_private_group_id, [:filename] => :environment do |task, args|
    PrettyConsole.announce_task(task) do
      if Rails.env.production? || Rails.env.development?
        counter = 0
        resource_file_location = "db/data_imports/#{args[:filename]}"
        # use with rake "retrofit:whitelist_dedoubling[email@domain.fr, Ministry, id_to_remove]"
        CSV.foreach(resource_file_location, 'r', headers: true, header_converters: :symbol, col_sep: ';').each do |row|
          id = row[:id]
          offer = InternshipOffers::WeeklyFramed.find_by(id: row[:id].to_i)
          entreprise = offer.try(:entreprise)
          next if offer.nil?
          next unless %w[VRAI FAUX].include?(row[:is_public])

          group_id = nil
          is_public = row[:is_public] == 'VRAI'
          if is_public
            group = Group.find_by(name: row[:type_employeur])
            if group.nil?
              error = "Group not found for type_employeur: #{row[:type_employeur]} and offer_id: #{offer.id}"
              PrettyConsole.puts_in_red(error)
              next
            end
            group_id = group.id
            is_offer_to_update = offer.group_id.nil? || offer.group_id != group_id
            is_entreprise_to_update = if entreprise.nil?
                                        false
                                      else
                                        entreprise.group_id.nil? || entreprise.group_id != group_id
                                      end
            next unless is_offer_to_update || is_entreprise_to_update
          else
            is_offer_to_update = offer.group_id.present?
            is_entreprise_to_update = entreprise.nil? ? false : entreprise.group_id.present?
            next unless is_offer_to_update || is_entreprise_to_update
          end

          offer.update_columns(group_id: group_id, is_public: is_public)
          entreprise.update_columns(group_id: group_id, is_public: true) unless entreprise.nil?

          counter += 1
          puts offer.id if counter % 10 == 0
          print '.' unless counter % 10 == 0
        end
      else
        PrettyConsole.say_in_yellow 'This task should be run in production or development environment'
      end
      PrettyConsole.say_in_green "#{counter} offers have been processed"
    end
  end

  desc '09/054/2025 - update offers from public offers without group_id'
  task fix_offers_groups: :environment do |task|
    PrettyConsole.announce_task(task) do
      if Rails.env.production? || Rails.env.development?
        counter = 0
        resource_file_location = 'db/data_imports/07_05_2025_data_bc.csv'
        CSV.foreach(resource_file_location, 'r', headers: true, header_converters: :symbol, col_sep: ';').each do |row|
          id = row[:id].to_i
          offer = InternshipOffer.find_by(id: id)
          entreprise = offer.try(:entreprise)
          next if offer.nil?

          # sector update
          if row[:secteur] != offer.sector.name
            new_sector = Sector.find_by(name: row[:secteur])
            if new_sector
              offer.sector_id = new_sector.id
              offer.save
              PrettyConsole.print_in_yellow '.'
            else
              PrettyConsole.puts_in_red "#{row[:secteur]} does not exist :/"
            end
          else
            PrettyConsole.print_in_cyan '.'
          end

          # public private treatment
          next unless %w[VRAI FAUX].include?(row[:public])

          group_id = nil
          is_public = row[:public] == 'VRAI'
          is_offer_to_update = true
          is_entreprise_to_update = true
          if offer.is_public == is_public
            if is_public
              group = Group.find_by(name: row[:public_employer_type])
              if group.nil?
                error = "Group not found for type_employeur: #{row[:type_employeur]} and offer_id: #{offer.id}"
                PrettyConsole.puts_in_red(error)
                next
              end
              group_id = group.id
              is_offer_to_update = offer.group_id.nil? || offer.group_id != group_id
              is_entreprise_to_update = if entreprise.nil?
                                          false
                                        else
                                          entreprise.group_id.nil? || entreprise.group_id != group_id
                                        end
            else
              is_offer_to_update = offer.group_id.present?
              is_entreprise_to_update = entreprise.nil? ? false : entreprise.group_id.present?
            end
            next unless is_offer_to_update || is_entreprise_to_update
          elsif is_public
            group = Group.find_by(name: row[:public_employer_type])
            if group.nil?
              error = "Group not found for type_employeur: #{row[:type_employeur]} and offer_id: #{offer.id}"
              PrettyConsole.puts_in_red(error)
              next
            end
            group_id = group.id
          else
            group_id = nil
          end
          offer.update_columns(group_id: group_id, is_public: is_public)
          entreprise.update_columns(group_id: group_id, is_public: is_public) unless entreprise.nil?
          counter += 1
          print '|'
        end

      else
        PrettyConsole.say_in_yellow 'This task should be run in production or development environment'
      end
      PrettyConsole.say_in_green "#{counter} offers have been processed"
    end
  end
end
