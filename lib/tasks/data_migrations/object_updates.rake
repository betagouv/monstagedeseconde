require 'pretty_console'

def decrease_size(model, field, size)
  puts '- ' * 10
  puts model.name
  puts field
  puts '*' * 10
  # candidates = model.pluck(field).compact.select { |value| value.length > size }
  # puts "#{candidates.count} records to update"
  model.find_each do |record|
    next if record.send(field)&.length.nil?
    next if record.send(field)&.length&.<= size

    record.update(field => record.send(field).truncate(size))
    print '.'
  end
end

# -----------------------------------------------------------------------------

namespace :data_migrations do
  desc 'create "lycees" from csv file'
  task 'add_info_to_schools': :environment do
    import 'csv'
    col_hash = { uai: 0, public_private: 1, contract_label: 2, contract_code: 3 }
    error_lines = []
    file_location = Rails.root.join('db/data_imports/school_public_prive.csv')
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      next if line_nr.zero?

      cells = row.to_s.split(';')

      uai = cells[col_hash[:uai]]
      next if uai.nil?

      school = School.find_by(code_uai: uai)
      next if school.nil?

      is_public = cells[col_hash[:public_private]].gsub("\n", '') == 'Public'
      contract_code = cells[col_hash[:contract_code]].gsub("\n", '')

      school_params = {
        is_public:,
        contract_code:
      }

      result = school.update(**school_params)
      if result
        print '.'
      else
        error_lines << ["Ligne #{line_nr}", school.name, school.errors.full_messages.join(', ')]
        print 'o'
      end
    end
    puts ''
    PrettyConsole.say_in_yellow 'Done with updating schools(lycées)'
  end

  desc 'use standard fields and no longer rich_text fields'
  task 'migrate_rich_text_fields': :environment do
    fields = [
      [InternshipApplication, %i[ motivation
                                  rejected_message
                                  canceled_by_employer_message
                                  canceled_by_student_message
                                  approved_message]]
      # rich_text_resume_other
      # rich_text_resume_languages
    ]

    fields.each do |model, attrs|
      # fields =  [%i[description_rich_text description]]]
      PrettyConsole.puts_in_green "Table: #{model.name}"
      puts '-------------------'
      attrs.each do |field|
        puts field
        puts('- ' * 10)
        model.find_each(batch_size: 300) do |record|
          key = "#{field}_tmp"
          value = record.send(field).to_plain_text
          next if value.blank?

          print 'o' if record.send(key.to_sym).present?
          next if record.send(key.to_sym).present?

          record.update(key => value)
          print '.'
        end
        puts ' '
      end
      puts '-------------------'
      puts ' '
    end
    # ===================
    fields = [
      [InternshipAgreement, %i[activity_scope
                               activity_preparation
                               activity_learnings
                               activity_rating
                               skills_observe
                               skills_communicate
                               skills_understand
                               skills_motivation]],
      # legal_terms_rich_text
      [School, %i[agreement_conditions]],
      [InternshipOfferInfo, %i[description]]
    ]

    fields.each do |model, attrs|
      PrettyConsole.puts_in_green "Table: #{model.name}"
      puts '-------------------'
      attrs.each do |attr|
        puts attr
        puts('- ' * 10)
        model.find_each(batch_size: 300) do |record|
          value = record.send("#{attr}_rich_text").to_plain_text
          next if value.blank?

          key = "#{attr}_tmp"
          print 'o' if record.send(key.to_sym).present?
          next if record.send(key.to_sym).present?

          record.update(key => value)
          print '.'
        end
        puts ' '
      end
      puts '-------------------'
      puts ' '
    end

    # ===================
    fields = [
      [Users::Student, %i[resume_educational_background
                          resume_other
                          resume_languages]]
    ]

    fields.each do |model, attrs|
      PrettyConsole.puts_in_green "Table: #{model.name}"
      puts '-------------------'
      attrs.each do |attr|
        puts attr
        puts('- ' * 10)
        model.find_each(batch_size: 300) do |record|
          value = record.send("#{attr}").to_plain_text
          next if value.blank?

          key = "#{attr}_tmp"
          print 'o' if record.send(key.to_sym).present?
          next if record.send(key.to_sym).present?

          record.update(key => value)
          print '.'
        end
        puts ' '
      end
      puts '-------------------'
      puts ' '
    end
  end

  desc 'decrease field size for some fields in tables'
  task 'decrease_field_size': :environment do
    PrettyConsole.announce_task('shrinking phase') do
      decrease_size(InternshipAgreement, :date_range, 70)
      decrease_size(InternshipAgreement, :tutor_full_name, 120)
      decrease_size(InternshipAgreement, :siret, 14)
      decrease_size(InternshipAgreement, :tutor_role, 200)
      decrease_size(InternshipAgreement, :organisation_representative_role, 250)
      decrease_size(InternshipAgreement, :organisation_representative_full_name, 120)
      decrease_size(InternshipAgreement, :student_phone, 20)
      decrease_size(InternshipAgreement, :school_representative_phone, 20)
      decrease_size(InternshipAgreement, :student_refering_teacher_phone, 20)
      decrease_size(InternshipAgreement, :student_refering_teacher_email, 100)
      decrease_size(InternshipAgreement, :student_legal_representative_phone, 100)
      decrease_size(InternshipAgreement, :student_legal_representative_2_full_name, 120)
      decrease_size(InternshipAgreement, :student_legal_representative_2_email, 100)
      decrease_size(InternshipAgreement, :student_legal_representative_2_phone, 20)
      decrease_size(InternshipAgreement, :school_representative_email, 100)

      decrease_size(InternshipApplication, :student_legal_representative_email, 100)
      decrease_size(InternshipApplication, :student_legal_representative_phone, 20)

      decrease_size(InternshipOffer, :title, 150)
      decrease_size(InternshipOffer, :tutor_name, 120)
      decrease_size(InternshipOffer, :employer_website, 300)
      decrease_size(InternshipOffer, :street, 300)

      decrease_size(Organisation, :employer_website, 300)

      decrease_size(User, :legal_representative_email, 100)
      decrease_size(User, :legal_representative_phone, 20)

      decrease_size(UsersSearchHistory, :city, 50)
    end
  end

  desc "update internship_offer's format from 2024 format to 2025's"
  task 'offers_format_update': :environment do
    PrettyConsole.announce_task("update internship_offer's format from 2024 format to 2025's") do
      older_offers = InternshipOffer.where('created_at < ?', Date.new(2024, 8, 1))
      # period enum : { full_time: 0, week_1: 1, week_2: 2 }
      first_week_2024 = SchoolTrack::Seconde.first_week(year: 2024)
      second_week_2024 = SchoolTrack::Seconde.second_week(year: 2024)

      older_offers.where(period: 0).find_each do |offer|
        offer.weeks = [first_week_2024, second_week_2024]
      end
      older_offers.where(period: 1).find_each do |offer|
        offer.weeks = [first_week_2024]
      end
      older_offers.where(period: 2).find_each do |offer|
        offer.weeks = [second_week_2024]
      end
    end
  end
end
