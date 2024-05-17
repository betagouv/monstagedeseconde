# frozen_string_literal: true

namespace :data_migrations do
  desc 'Import data from MS3E'
  task :import_offers_from_ms3e, [:url] => :environment do |task, args|
  
    require 'csv'
    require 'open-uri'

    if args[:url].nil?
      puts "You must provide a file path"
      exit
    end

    file = URI.open(args[:url])
    csv_options = { headers: true, header_converters: :symbol }
    
    begin
      ActiveRecord::Base.transaction do

        CSV.parse(URI.open(args[:url]).read, headers: true) do |row|
          begin
            user = User.find_by(email: row['email'])
            puts '.'

            unless user
              user = Users::Employer.create!(
                first_name: row['first_name'],
                last_name: row['last_name'],
                email: row['email'],
                password: 'password',
                employer_role: row['employer_role'],
                password: 'Temp1234678!'
              )

              user.update_attribute(:confirmed_at, Time.now)
              user.update_attribute(:encrypted_password, row['encrypted_password'])
            end

            organisation = Organisation.create!(
              siret: row['siret'],
              employer_name: row['employer_name'],
              street: row['street'],
              zipcode: row['zipcode'],
              city: row['city'],
              employer_description: row['employer_description'],
              employer_website: row['employer_website'],
              is_public: row['is_public'],
              coordinates: row['coordinates'],
              employer_id: user.id
            )

            sector = Sector.find_by(name: row['sector'])

            internship_offer_info = InternshipOfferInfo.create!(
              title: row['title'],
              description: row['description'],
              sector_id: sector.try(:id) || Sector.first.id,
              employer_id: user.id,
            )

            contact_phone = row['contact_phone'].present? ? (row['contact_phone'].size == 9 ? '0' + row['contact_phone'] : row['contact_phone']) : '0123456789'
            
            practical_infos = PracticalInfo.create!(
              street: row['street'],
              zipcode: row['zipcode'],
              city: row['city'],
              coordinates: row['coordinates'],
              daily_hours: eval(row['daily_hours']),
              weekly_hours: eval(row['weekly_hours']),
              lunch_break: row['lunch_break'].present? ? row['lunch_break'] : 'Pause déjeuner',
              contact_phone: contact_phone,
              employer_id: user.id
            )

            hosting_infos = HostingInfo.create!(
              max_candidates: row['max_candidates'],
              period: 0,
              employer_id: user.id
            )

            Builders::InternshipOfferBuilder.new(user: user, context: :web).create_from_stepper(
              organisation: organisation,
              internship_offer_info: internship_offer_info,
              practical_info: practical_infos,
              hosting_info: hosting_infos
            ) do |on|
              on.success do |created_internship_offer|
                created_internship_offer.update(aasm_state: 'published')
                created_internship_offer.update_attribute(internship_area_id: user.current_area_id)

                Rails.logger.info("Created offer: #{created_internship_offer.id}")
                Rails.logger.info("Created offer area id: #{created_internship_offer.internship_area_id}")

                puts "Created offer: #{created_internship_offer.id}"
              end
              on.failure do |failed_internship_offer|
                puts "X Failed to create offer: #{failed_internship_offer.errors.full_messages}"
                puts failed_internship_offer.errors.full_messages
              end
            end

            rescue StandardError => e
              Rails.logger.error("Error processing row: #{row.inspect}, Error: #{e.message}")
            end
          end
        end
      rescue StandardError => e
        Rails.logger.error("Failed to complete import: #{e.message}")
      end
  

  end
end