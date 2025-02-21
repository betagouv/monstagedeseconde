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
        next if offer.weeks.present? && offer.weeks.map(&:id).sort == [first_week_2024.id, second_week_2024.id].sort

        offer.weeks = [first_week_2024, second_week_2024]
        offer.save
        print('.')
      end
      older_offers.where(period: 1).find_each do |offer|
        next if offer.weeks.present? && offer.weeks.first.id == first_week_2024.id

        offer.weeks = [first_week_2024]
        offer.save
        print('.')
      end
      older_offers.where(period: 2).find_each do |offer|
        next if offer.weeks.present? && offer.weeks.first.id == second_week_2024.id

        offer.weeks = [second_week_2024]
        offer.save
        print('.')
      end
    end
  end

  desc 'add missing grades to weekly offers when missing'
  task 'add_missing_grades_to_weekly_offers': :environment do
    # at the time it is played this task consider all older offers are seconde offers
    PrettyConsole.announce_task('add missing grades to weekly offers when missing') do
      counter = 0
      InternshipOffers::WeeklyFramed.kept.each do |offer|
        next unless offer.grades.empty?

        counter += 1
        offer.grades << Grade.seconde
        print '.'
      end
      puts '================================'
      puts "counter : #{counter}"
      puts '================================'
      puts ''
    end
  end

  desc 'corrections on internship_offers'
  task 'fix_internship_offers': :environment do
    PrettyConsole.announce_task('transit from draft to unpublish on every internship_offer') do
      counter = 0
      offers = Rails.env.development? ? InternshipOffer.kept.where(school_id: nil) : InternshipOffer.kept
      offers.find_each do |offer|
        saved_offer = offer.dup
        conditions = offer.lunch_break.nil? ||
                     offer.lunch_break.length < 8 ||
                     offer.lunch_break.length > 200 ||
                     offer.employer_name.length > 80 ||
                     offer.contact_phone.blank? ||
                     offer.contact_phone.length > 20 ||
                     !offer.contact_phone.match?(/^\+?(\d{2,3}\s?)?(\d{1,2}\s?){3,4}\d{2}$/) ||
                     offer.grades.empty? ||
                     offer.weeks.empty?
        if conditions
          if offer.is_a?(InternshipOffers::WeeklyFramed)
            offer.lunch_break = 'A définir précisément' if offer.lunch_break.nil?
            offer.lunch_break = offer.lunch_break.ljust(8, '.') if offer.lunch_break.length < 8
            offer.lunch_break = offer.lunch_break.truncate(200, omission: '...') if offer.lunch_break.length > 200
            offer.contact_phone = '0606060606' if offer.contact_phone.blank?
            offer.contact_phone = offer.contact_phone.strip
            unless offer.contact_phone.match?(/^\+?(\d{2,3}\s?)?(\d{1,2}\s?){3,4}\d{2}$/)
              offer.contact_phone = User.sanitize_mobile_phone_number(offer.contact_phone)
            end
            if offer.contact_phone.length > 20
              offer.contact_phone = offer.contact_phone.strip.truncate(20,
                                                                       omission: '...')
            end
          end

          offer.employer_name = offer.employer_name.truncate(80, omission: '...') if offer.employer_name.length > 80
          offer.grades = [Grade.seconde] if offer.grades.empty?
          if offer.weeks.empty?
            first_week_2024 = SchoolTrack::Seconde.first_week(year: 2024)
            second_week_2024 = SchoolTrack::Seconde.second_week(year: 2024)
            both_weeks = [first_week_2024, second_week_2024]
            offer.weeks = [Week.current_year_start_week]
            offer.weeks = both_weeks if offer.period == 0
            offer.weeks = [first_week_2024] if offer.period == 1
            offer.weeks = [second_week_2024] if offer.period == 2
          end

          unless offer.valid?
            puts '================================'
            puts "offer.id : #{offer.id}"
            puts "offer.errors.full_messages : #{offer.errors.full_messages}"
            puts '================================'
            puts ''
          end
          if offer.lunch_break != saved_offer.lunch_break ||
             offer.employer_name != saved_offer.employer_name ||
             offer.contact_phone != saved_offer.contact_phone ||
             offer.grades != saved_offer.grades ||
             offer.weeks != saved_offer.weeks
            offer.save!
            print 'x'
            counter += 1
          else
            PrettyConsole.print_in_green 'o'
          end
        else
          PrettyConsole.print_in_yellow '-'
        end
      end
      PrettyConsole.say_in_cyan "offers updated : #{counter}"
    end
  end

  desc 'update schools where department is missing'
  task 'update_schools_department': :environment do
    PrettyConsole.announce_task('update schools where department is missing') do
      counter = 0
      School.all.each do |school|
        counter += 1

        if school.department.present?
          print 'o'
        else
          department = Department.fetch_by_zipcode(zipcode: school.zipcode)
          if department.nil?
            print 'x'
          else
            school.update!(department_id: department.id)
            print '.'
          end
        end
      end
      PrettyConsole.say_in_cyan "counter of schools updated : #{counter}"
    end
  end

  desc 'obfuscate readable students ine at setup' do
    task 'obfuscate_email': :environment do
      Users::Student.kept
                    .where('created_at < ?', DateTime.new(2025, 1, 31, 19, 20))
                    .where.not(ine: nil)
                    .find_each do |student|
        scrambled_ine = Digest::SHA1.hexdigest(student.ine)
        student.update_columns(email: "#{scrambled_ine}@#{student.school.code_uai}.fr")
        print '.'
      end
    end
  end

  desc 'update lycees and colleges with qpv information'
  task 'update_schools_qpv': :environment do
    PrettyConsole.announce_task('update lycees with qpv information') do
      School.where(rep_kind: 'qpv').find_each do |school|
        school.update!(qpv: true, rep_kind: '')
        print '.'
      end
    end
    PrettyConsole.announce_task('update lycees with qpv information') do
      file_location = Rails.root.join('db/data_imports/sources_EN/LYCEE_220524_simplified.csv')
      counter = 0
      CSV.foreach(file_location, headers: { col_sep: ';' }).each do |row|
        fields = row.to_s.split(';')
        code_uai = fields.second.strip
        # rep = fields[3].upcase.strip == 'OUI'
        # rep_plus = fields[4].upcase.strip == 'OUI'
        qpv = fields[5].upcase.strip == 'DANS QP'

        school = School.find_by(code_uai: code_uai, qpv: false)
        next if school.nil?

        school.update!(qpv: qpv)
        print '.'
        counter += 1
      end
      PrettyConsole.say_in_cyan "counter of lycees updated : #{counter}"
    end
    PrettyConsole.announce_task('update colleges with qpv information') do
      file_location = Rails.root.join('db/data_imports/sources_EN/fr-colleges-qpv.csv')
      counter = 0
      CSV.foreach(file_location, headers: { col_sep: ';' }).each do |row|
        fields = row.to_s.split(';')
        code_uai = fields.first.strip
        qpv = fields.second.upcase.strip == 'DANS UN QPV'
        next unless qpv

        school = School.find_by(code_uai: code_uai, qpv: false)
        next if school.nil?

        school.update!(qpv: qpv)
        print '.'
        counter += 1
      end
      PrettyConsole.say_in_cyan "counter of colleges updated : #{counter}"
    end
  end

  desc '2025-02-21 update internship_offer with targeted_grades'
  task 'update_internship_offers_targeted_grades': :environment do
    PrettyConsole.announce_task('update internship_offer with targeted_grades') do
      seconde_troisieme_or_quatrieme_grades = Grade.all.sort_by(&:id).map(&:id)
      troisieme_or_quatrieme_grades = Grade.troisieme_et_quatrieme.map(&:id)
      seconde_only_grade = [Grade.seconde.id]

      InternshipOffer.where('updated_at > ?', Date.new(2024,8,1))
                     .find_each do |offer|
        sorted_grade_ids = offer.grades.sort_by(&:id).map(&:id)
        next if sorted_grade_ids == seconde_only_grade # default value, nothing to do

        if sorted_grade_ids == seconde_troisieme_or_quatrieme_grades
          offer.targeted_grades = 'seconde_troisieme_or_quatrieme'
        elsif sorted_grade_ids == troisieme_or_quatrieme_grades
          offer.targeted_grades = 'troisieme_or_quatrieme'
        else
          Rails.logger.error("Unknown grade_ids: #{offer.grade_ids} for offer_id: #{offer.id}")
        end
        offer.save
        print '.'
      end
    end
  end
end
