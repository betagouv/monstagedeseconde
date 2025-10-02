# frozen_string_literal: true

require 'open-uri'

desc 'Import new offers'
task :import_weekly_framed_offers, %i[employer_id csv_uri] => :environment do |t, args|
  weeks = Week.selectable_from_now_until_end_of_school_year.map(&:id)
  employer = Users::Employer.find(args[:employer_id])
  created_count = 0
  errors_count = 0

  csv_data = open(args[:csv_uri]).read

  CSV.parse(csv_data).each do |row|
    employer_name = row[0]
    street = row[2]
    zipcode = row[3]
    city = row[4]
    title = row[5]
    description = row[6]
    sector = row[7]
    max_candidates = row[10]
    tutor_name = row[13]
    tutor_email = row[14]
    tutor_phone = row[15]

    address = "#{street} #{zipcode} #{city}"
    coordinates = Geocoder.search(address).first.try(:coordinates)
    coordinates ||= Geocoder.search("#{zipcode} #{city}").first.try(:coordinates)

    if coordinates
      offer = InternshipOffer.new(
        employer_name:,
        is_public: false,
        street:,
        zipcode:,
        city:,
        type: InternshipOffers::WeeklyFramed,
        title:,
        sector_id: sector,
        description: "<div>#{description}</div>",
        max_candidates:,
        tutor_name:,
        tutor_email:,
        tutor_phone:,
        week_ids: weeks,
        weekly_hours: ['9:00', '17:00'],
        coordinates: { latitude: coordinates[0], longitude: coordinates[1] },
        employer:
      )

      if offer.save
        puts "offer created : ##{offer.id}"
        created_count += 1
      else
        puts 'ERROR : '
        p offer.errors.messages
        errors_count += 1
      end
    else
      puts "ERROR : address not found : #{address}"
      errors_count += 1
    end
    puts '---------'
  end

  puts '---------'
  puts '---END---'
  puts '---------'
  puts "#{errors_count} errors."
  puts "#{created_count} offers created !"
end

desc 'Import new offers'
task :import_weekly_framed_offers_with_employers_already_created, [:csv_uri] => :environment do |t, args|
  created_count = 0
  errors_count = 0

  csv_data = open(args[:csv_uri]).read

  CSV.parse(csv_data).each do |row|
    employer_name = row[0]
    street = row[2]
    zipcode = row[3]
    city = row[4]
    title = row[5]
    description = row[6]
    sector = row[7]
    max_candidates = row[10]
    weeks = row[11].split('-').map { |w| Week.find_by(number: w.to_i, year: Date.current.year).id }
    tutor_name = row[13]
    tutor_email = row[14]
    tutor_phone = row[15]

    address = "#{street} #{zipcode} #{city}"
    coordinates = Geocoder.search(address).first.try(:coordinates)
    coordinates ||= Geocoder.search("#{zipcode} #{city}").first.try(:coordinates)

    employer = Users::Employer.where(email: tutor_email).first

    if coordinates && employer
      offer = InternshipOffer.new(
        employer_name:,
        is_public: false,
        street:,
        zipcode:,
        city:,
        type: InternshipOffers::WeeklyFramed,
        title:,
        sector_id: sector,
        description: "<div>#{description}</div>",
        max_candidates:,
        tutor_name:,
        tutor_email:,
        tutor_phone:,
        week_ids: weeks,
        weekly_hours: ['9:00', '17:00'],
        coordinates: { latitude: coordinates[0], longitude: coordinates[1] },
        employer:
      )

      if offer.save
        puts "offer created : ##{offer.id}"
        created_count += 1
      else
        puts 'ERROR : '
        p offer.errors.messages
        errors_count += 1
      end
    else
      puts "ERROR : address or employer not found : #{address} / #{tutor_email}"
      errors_count += 1
    end
    puts '---------'
  end

  puts '---------'
  puts '---END---'
  puts '---------'
  puts "#{errors_count} errors."
  puts "#{created_count} offers created !"
end

desc 'Import new offers 3 steps september 2025'
task :import_offers_in_4_steps, [:csv_uri] => :environment do |t, args|
  puts '---------'
  puts args[:csv_uri]
  puts '---------'

  created_count = 0
  errors = []
  csv_data = URI.open(args[:csv_uri]).read

  # Column 0 : Company name
  # Column 1 : SIRET
  # Column 2 : Employer name
  # Column 3 : Employer first name
  # Column 4 : Employer email
  # Column 5 : Employer phone
  # Column 6 : Employer description
  # Column 7 : Private or Public
  # Column 8 : Street
  # Column 9 : Zipcode
  # Column 10 : City
  # Column 11 : Offer Title
  # Column 12 : Offer Description
  # Column 13 : Offer Sector
  # Column 14 : Offer Activities
  # Column 15 : Offer Max candidates
  # Column 16 : Offer weeks
  # Column 17 : Offer weekly hours start
  # Column 18 : Offer weekly hours end
  # Column 19 : Offer lunch break
  # Column 20 : Schools UAI (separated by commas)

  

  created_employers = []

  CSV.parse(csv_data).each_with_index do |row, i|
    next if i < 2

    puts row

    puts '---------'
    puts "col1 : Company name #{row[0]}"
    puts "col2 : SIRET #{row[1]}"
    puts "col3 : Employer name #{row[2]}"
    puts "col4 : Employer first name #{row[3]}"
    puts "col5 : Employer email #{row[4]}"
    puts "col6 : Employer phone #{row[5]}"
    puts "col7 : Employer description #{row[6]}"
    puts "col8 : Private or Public #{row[7]}"
    puts "col9 : Street #{row[8]}"
    puts "col10 : Zipcode #{row[9]}"
    puts "col11 : City #{row[10]}"
    puts "col12 : Offer Title #{row[11]}"
    puts "col13 : Offer Description #{row[12]}"
    puts "col14 : Offer Sector #{row[13]}"
    puts "col15 : Offer Activities #{row[14]}"
    puts "col16 : Offer Max candidates #{row[15]}"
    puts "col17 : Offer weeks #{row[16]}"
    puts "col18 : Offer weekly hours start #{row[17]}"
    puts "col19 : Offer weekly hours end #{row[18]}"
    puts "col20 : Offer lunch break #{row[19]}"
    puts "col21 : Schools UAI #{row[20]}"
    puts '---------'

    employer_name = row[0]
    siret = row[1].to_s.strip
    email = row[4]
    employer = Users::Employer.where(email:).first

    unless employer
      password = Devise.friendly_token.first(20) + 'A@'

      employer = Users::Employer.create(
        email:,
        first_name: row[3],
        last_name: row[2],
        password:
      )
      
      if employer.save
        puts "employer created : ##{employer.id}"

        employer.update(
          confirmed_at: Time.current
        )

        

        created_employers << { email:, password: }
      else
        puts "ERROR employer : "
        p employer.errors.messages
        errors << [i, email, employer.errors.messages]
      end
    end

    if employer.current_area_id.nil?
      a = InternshipOfferArea.create(
        employer_id: employer.id,
        employer_type: 'User',
        name: 'Mon espace'
      )
      employer.update(current_area_id: a.id)
    end

    contact_phone = row[5]
    is_public = row[7] == 'Public'
    street = row[8]
    zipcode = row[9].to_s.strip
    city = row[10]
    title = row[11]
    description = row[12] ? row[12][0..480] : 'Découverte du métier'
    sector_id = Sector.where(name: row[13]).first.try(:id) || Sector.first.id

    max_candidates = row[15].to_i && row[15].to_i > 0 ? row[15].to_i : 1
    weeks = row[16].split(',').map { |w| Week.find_by(number: w.to_i, year: Date.current.year) }
    weekly_hours = [row[17], row[18]]
    lunch_break = row[19]

    address = "#{street} #{zipcode} #{city}"
    coordinates = Geocoder.search(address).first.try(:coordinates)
    coordinates ||= Geocoder.search("#{zipcode} #{city}").first.try(:coordinates)
    coordinates ||= Geocoder.search(city).first.try(:coordinates)

    schools = row[20].split(',').map { |uai| School.find_by(code_uai: uai) }.compact

    if address.present? && coordinates
      # Step 1 : Internship Occupation
      internship_occupation = InternshipOccupation.new(
        title:,
        description: "<div>#{description}</div>",
        employer:,
        street:,
        zipcode:,
        city:,
        coordinates: { latitude: coordinates[0], longitude: coordinates[1] }
      )

      if internship_occupation.save
        puts "internship_occupation created : ##{internship_occupation.id}"

        # Step 2 :Enterprise
        entreprise = Entreprise.new(
          employer_name:,
          is_public:,
          entreprise_coordinates: { latitude: coordinates[0], longitude: coordinates[1] },
          siret:,
          entreprise_full_address: address,
          sector_id:,
          internship_occupation_id: internship_occupation.id,
          contact_phone: contact_phone
        )

        if entreprise.save
          puts "entreprise created : ##{entreprise.id}"

          # Step 3 : Planning
          planning = Planning.new(
            weeks:,
            max_candidates:,
            entreprise_id: entreprise.id,
            weekly_hours: weekly_hours,
            lunch_break: lunch_break,
            schools: schools,
            grades: Grade.troisieme_et_quatrieme
          )

          if planning.save
            puts "planning created : ##{planning.id}"

            # Create offer
              Builders::InternshipOfferBuilder.new(user: employer, context: :web).create_from_stepper(
                planning:,
                user: employer
              ) do |on|
                on.success do |offer|
                  offer.publish! unless offer.published?
                  puts "offer created : ##{offer.id}"
                  puts "offer published : ##{offer.contact_phone}"
                  created_count += 1
                end
                on.failure do |failed_offer|
                  puts 'ERROR Internship Offer : '

                  p failed_offer.errors.messages
                  errors << [i, email, failed_offer.errors.messages]
                end
              end
          else
            puts 'ERROR planning : '
            p planning.errors.messages
            errors << [i, email, planning.errors.messages]
          end
        else
          puts 'ERROR entreprise : '
          p entreprise.errors.messages
          errors << [i, entreprise.siret, entreprise.errors.messages]
        end
      else
        puts 'ERROR internship_occupation : '
        p internship_occupation.errors.messages
        errors << [i, internship_occupation.title, internship_occupation.errors.messages]
      end

    else
      puts "ERROR : address or employer not found : #{address}"
      errors << title
    end
    puts '---------'
  end

  puts '---------'
  puts '---END---'
  puts '---------'
  puts "#{errors.count} errors."
  if errors.count > 0
    puts '################'
    puts 'Errors :'
    errors.each do |error|
      puts "Ligne #{error[0]} (#{error[1]}) - #{error[2]}"
    end
    puts '################'
  end
  if created_employers.count > 0
    puts '################'
    puts 'New employers created :'
    created_employers.each do |employer|
      puts "#{employer[:email]} - #{employer[:password]}"
    end
    puts '################'
  end
  puts "#{created_count} offers created !"
end
