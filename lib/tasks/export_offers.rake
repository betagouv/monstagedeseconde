# frozen_string_literal: true

namespace :offers do
  desc 'Export published offers from a specific zipcode prefix (2 digits)'
  task :export_offers, [:zipcode_prefix] => :environment do |_task, args|
    zipcode_prefix = args[:zipcode_prefix]

    if zipcode_prefix.blank?
      puts 'Usage: rake offers:export_offers[75]'
      puts 'Usage: rake offers:export_offers[13]'
      exit 1
    end

    puts "Exporting published offers for zipcode prefix: #{zipcode_prefix}"

    # Find offers with zipcode starting with the specified prefix
    offers = InternshipOffer.published
                            .where('zipcode LIKE ?', "#{zipcode_prefix}%")
                            .includes(:sector, :weeks, :grades)

    if offers.empty?
      puts "No published offers found for zipcode prefix #{zipcode_prefix}"
      exit 0
    end

    puts "Found #{offers.count} offers"

    # Generate CSV
    require 'csv'

    csv_data = CSV.generate(headers: true, col_sep: ';') do |csv|
      # Headers
      csv << [
        'ID',
        'Titre',
        'Description',
        'Nom employeur',
        'URL',
        'Ville',
        'Code postal',
        'Rue',
        'Date début',
        'Date fin',
        'Latitude',
        'Longitude',
        'Image secteur',
        'Secteur',
        'Accessible handicap',
        'Période',
        'Semaines',
        'ID distant',
        'Public',
        'Site web employeur',
        'Description employeur',
        'Niveaux',
        'Permalien'
      ]

      # Data rows
      offers.each do |offer|
        csv << [
          offer.id,
          offer.title,
          offer.description.to_s,
          offer.employer_name,
          "https://1eleve1stage.education.gouv.fr/internship_offers/#{offer.id}",
          offer.city&.capitalize,
          offer.zipcode,
          offer.street,
          offer.first_date&.strftime('%d/%m/%Y'),
          offer.last_date&.strftime('%d/%m/%Y'),
          offer.coordinates&.latitude,
          offer.coordinates&.longitude,
          offer.sector&.cover,
          offer.sector&.name,
          offer.handicap_accessible,
          offer.period,
          offer.weeks_api_formatted,
          offer.remote_id,
          offer.is_public,
          offer.employer_website,
          offer.employer_description,
          offer.grades_api_formatted,
          offer.permalink
        ]
      end
    end

    # Write to file
    filename = "offers_zipcode_#{zipcode_prefix}_#{Date.current.strftime('%Y%m%d')}.csv"
    filepath = Rails.root.join('tmp', filename)

    File.write(filepath, csv_data)

    # Send by email using GodMailer
    if ENV['TEAM_EMAIL'].present?
      begin
        GodMailer.export_offers_department(
          department_code: zipcode_prefix,
          offers_count: offers.count,
          csv_data: csv_data,
          filename: filename
        ).deliver_now

        puts "✅ Export sent by email to: #{ENV['TEAM_EMAIL']}"
      rescue StandardError => e
        puts "❌ Email sending failed: #{e.message}"
        puts 'CSV content available in logs above'
      end
    else
      puts '⚠️  TEAM_EMAIL not set. CSV content:'
      puts '=' * 50
      puts csv_data
      puts '=' * 50
    end

    puts "Export completed: #{filepath}"
    puts "Total offers exported: #{offers.count}"
  end
end
