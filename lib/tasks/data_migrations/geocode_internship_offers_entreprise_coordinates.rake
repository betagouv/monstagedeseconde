# frozen_string_literal: true

require 'pretty_console'

namespace :data_migrations do
  desc 'Geocode entreprise_coordinates for internship_offers from entreprise_full_address'
  task geocode_internship_offers_entreprise_coordinates: :environment do |task|
    PrettyConsole.puts_with_white_background "Starting task : #{task.name}"

    failed_offers = []
    success_count = 0
    skipped_count = 0

    # Find all offers where entreprise_coordinates is empty/nil or at (0, 0)
    # and where entreprise_full_address is present
    # Use SQL query to check for NULL geographic fields or coordinates at (0, 0)
    offers_to_geocode = InternshipOffer.kept.where('created_at > ?', 3.month.ago).where(
      'entreprise_coordinates IS NULL OR (ST_X(entreprise_coordinates::geometry) = 0 AND ST_Y(entreprise_coordinates::geometry) = 0)'
    ).where.not(entreprise_full_address: [nil, ''])

    total_count = offers_to_geocode.count
    PrettyConsole.say_in_cyan "Found #{total_count} offers to geocode"

    offers_to_geocode.find_each do |offer|
      if offer.entreprise_full_address.blank?
        skipped_count += 1
        next
      end

      # Skip if coordinates are already set and not at (0, 0)
      if offer.entreprise_coordinates.present? &&
         offer.entreprise_coordinates.latitude != 0 &&
         offer.entreprise_coordinates.longitude != 0
        skipped_count += 1
        next
      end

      # Use Geofinder to geocode the address
      coordinates = Geofinder.coordinates(offer.entreprise_full_address)

      if coordinates.present? && coordinates.length == 2
        begin
          # Update coordinates
          offer.entreprise_coordinates = {
            latitude: coordinates[0],
            longitude: coordinates[1]
          }

          if offer.save
            success_count += 1
            print '.'
          else
            failed_offers << {
              id: offer.id,
              reason: "Validation failed: #{offer.errors.full_messages.join(', ')}",
              address: offer.entreprise_full_address
            }
            print 'F'
          end
        rescue StandardError => e
          failed_offers << {
            id: offer.id,
            reason: "Exception: #{e.message}",
            address: offer.entreprise_full_address
          }
          print 'E'
        end
      else
        # Coordinates not found by Geocoder, try to copy from coordinates field
        if offer.coordinates.present?
          begin
            offer.entreprise_coordinates = offer.coordinates
            if offer.save
              success_count += 1
              print 'C' # C for copied
            else
              failed_offers << {
                id: offer.id,
                reason: "Validation failed when copying coordinates: #{offer.errors.full_messages.join(', ')}",
                address: offer.entreprise_full_address
              }
              print 'F'
            end
          rescue StandardError => e
            failed_offers << {
              id: offer.id,
              reason: "Exception when copying coordinates: #{e.message}",
              address: offer.entreprise_full_address
            }
            print 'E'
          end
        else
          # No coordinates available to copy
          failed_offers << {
            id: offer.id,
            reason: 'Coordinates not found by Geocoder and no coordinates field to copy',
            address: offer.entreprise_full_address
          }
          print 'X'
        end
      end

      # Small pause to avoid overloading the Geocoder API
      sleep(0.1) if success_count % 10 == 0
    end

    puts ''
    puts '=' * 80
    PrettyConsole.say_in_green "Successfully geocoded: #{success_count} offers"
    PrettyConsole.say_in_yellow "Skipped: #{skipped_count} offers"
    PrettyConsole.say_in_red "Failed: #{failed_offers.count} offers"

    if failed_offers.any?
      puts ''
      PrettyConsole.say_in_red 'Failed offers details:'
      puts '-' * 80
      failed_offers.each do |failed|
        puts "ID: #{failed[:id]}"
        puts "  Address: #{failed[:address]}"
        puts "  Reason: #{failed[:reason]}"
        puts ''
      end

      # Also save to a file
      error_file = Rails.root.join('tmp', "geocode_failed_offers_#{Time.now.strftime('%Y%m%d_%H%M%S')}.txt")
      File.open(error_file, 'w') do |f|
        f.puts "Failed offers geocoding - #{Time.now}"
        f.puts '=' * 80
        f.puts ''
        failed_offers.each do |failed|
          f.puts "ID: #{failed[:id]}"
          f.puts "  Address: #{failed[:address]}"
          f.puts "  Reason: #{failed[:reason]}"
          f.puts ''
        end
      end
      PrettyConsole.say_in_cyan "Failed offers saved to: #{error_file}"
    end

    puts '=' * 80
    PrettyConsole.say_in_green 'Task completed'
  end
end

