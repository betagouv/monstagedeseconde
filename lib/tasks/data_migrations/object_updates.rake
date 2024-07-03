require 'pretty_console'
namespace :data_migrations do

  desc 'create "lycees" from csv file'
  task 'add_info_to_schools': :environment do
    import 'csv'
    col_hash= { uai: 0, public_private: 1,  contract_label: 2, contract_code: 3}
    error_lines = []
    file_location = Rails.root.join('db/data_imports/school_public_prive.csv')
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      next if line_nr.zero?

      cells = row.to_s.split(';')

      uai = cells[col_hash[:uai]]
      next if uai.nil?
      school = School.find_by(code_uai: uai)
      next if school.nil?

      is_public = cells[col_hash[:public_private]].gsub("\n", '') == "Public"
      contract_code = cells[col_hash[:contract_code]].gsub("\n", '')

      school_params = {
        is_public: is_public,
        contract_code: contract_code
      }

      result = school.update(**school_params)
      if result
        print "."
      else
        error_lines << ["Ligne #{line_nr}" , school.name, school.errors.full_messages.join(", ")]
        print "o"
      end
    end
    puts ""
    PrettyConsole.say_in_yellow  "Done with updating schools(lycées)"
  end

  desc 'use standard fields and no longer rich_text fields'
  task 'migrate_rich_text_fields': :environment do
    fields = [
      [InternshipApplication, %i[ motivation
                                rejected_message
                                canceled_by_employer_message]]
                                  # rich_text_resume_other
                                  # rich_text_resume_languages
    ]

    fields.each do |model, attrs|
      # fields =  [%i[description_rich_text description]]]
      PrettyConsole.puts_in_green "Table: #{model.name}"
      puts '-------------------'
      attrs.each do |field|
        puts field
        puts("- " * 10)
        model.find_each(batch_size: 300) do |record|
          key = "#{field}_tmp"
          value = record.send(field).to_plain_text
          next if value.blank?

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
    ]

    fields.each do |model, attrs|
      PrettyConsole.puts_in_green "Table: #{model.name}"
      puts '-------------------'
      attrs.each do |attr|
        puts attr
        puts("- " * 10)
        model.find_each(batch_size: 300) do |record|
          value = record.send("#{attr}_rich_text").to_plain_text
          next if value.blank?

          key = "#{attr}_tmp"
          record.update(key => value)
          print '.'
        end
        puts ' '
      end
      puts '-------------------'
      puts ' '
    end
  end

  desc "set max length to db varchar fields"
  task 'set_column_size': :environment do
      # DECREASE COLUMN SIZE CANDIDATE
  # REFERENCE SIZE

    # internship_agreement
      # date_range character varying(210) NOT NULL,
    # organisation_representative_full_name character varying,
    # school_representative_full_name character varying,
    # student_full_name character varying,
    # student_class_room character varying,
    # tutor_full_name character varying,
      # siret character varying(16),
      # tutor_role character varying(500),
      # organisation_representative_role character varying(500),
      # student_phone character varying(200),
      # school_representative_phone character varying(100),
      # student_refering_teacher_phone character varying(100),
      # student_legal_representative_email character varying(180),
  # student_refering_teacher_email character varying(100),
      # student_legal_representative_full_name character varying(180),
      # student_refering_teacher_full_name character varying(180),
      # student_legal_representative_phone character varying(250),
      # student_legal_representative_2_email character varying(120),
      # student_legal_representative_2_phone character varying(250),
      # school_representative_role character varying(200),
      # school_representative_email character varying(180),
      # internship_address character varying(500),
# employer_name character varying(180),
        # date_rang character_varying(210),
        # tutor_full_name character_varying(275),
    update_column :internship_agreements, :date_range, :string, limit: 210
    update_column :internship_agreements, :organisation_representative_full_name, :string, limit: 100
    update_column :internship_agreements, :student_full_name, :string, limit: 100
    update_column :internship_agreements, :student_class_room, :string, limit: 50
    update_column :internship_agreements, :tutor_full_name, :string, limit: 275

    # identities (
    # first_name character varying,
    # last_name character varying,
    # gender character varying DEFAULT 'np'::character varying,
    # token character varying,
      # first_name character varying(82),
      # last_name character varying(82),
    update_column :identities, :first_name, :string, limit: 82
    update_column :identities, :last_name, :string, limit: 82

    # academies (
    # name character varying,
    # email_domain character varying,
    update_column :academies, :name, :string, limit: 40
    update_column :academies, :email_domain, :string, limit: 100

    # academy_regions (
    # name character varying,
    update_column :academy_regions, :name, :string, limit: 40

    # class_rooms (
    # name character varying,
    update_column :class_rooms, :name, :string, limit: 40

    # crafts (
    # number character varying NOT NULL,
    update_column :crafts, :number, :string, limit: 5

    # departments (
    # code character varying,
    # name character varying,
    update_column :departments, :code, :string, limit: 5
    update_column :departments, :name, :string, limit: 40

    # detailed_crafts (
    # number character varying NOT NULL,
    update_column :detailed_crafts, :name, :string, limit: 120

    # groups (
    # name character varying,
    update_column :groups, :name, :string, limit: 150

    # internship_applications (
    # aasm_state character varying,
    # type character varying DEFAULT 'InternshipApplications::WeeklyFramed'::character varying,
    # applicable_type character varying,
    # student_phone character varying,
    # student_email character varying,
    # access_token character varying,
    # student_address character varying,
    # student_legal_representative_full_name character varying(150),
    # student_legal_representative_email character varying(109),
    # student_legal_representative_phone character varying(50),
    update_column :internship_applications, :aasm_state, :string, limit: 100
    update_column :internship_applications, :type, :string, limit: 100
    update_column :internship_applications, :applicable_type, :string, limit: 100
    update_column :internship_applications, :student_phone, :string, limit: 20
    update_column :internship_applications, :student_email, :string, limit: 100
    update_column :internship_applications, :access_token, :string, limit: 20
    update_column :internship_applications, :student_address, :string, limit: 300

    # internship_offer_areas (
    # employer_type character varying,
    # name character varying,
    update_column :internship_offer_areas, :employer_type, :string, limit: 50
    update_column :internship_offer_areas, :name, :string, limit: 150

    # internship_offer_infos (
    # title character varying,
    # type character varying,
    update_column :internship_offer_infos, :title, :string, limit: 150
    update_column :internship_offer_infos, :type, :string, limit: 50

    # internship_offers (
    # title character varying,
    # description character varying,
    # tutor_name character varying,
    # tutor_phone character varying,
    # tutor_email character varying,
    # employer_website character varying,
    # street character varying,
    # zipcode character varying,
    # city character varying,
    # employer_name character varying,
    # employer_description character varying,
    # employer_type character varying,
    # department character varying DEFAULT ''::character varying NOT NULL,
    # academy character varying(50) DEFAULT ''::character varying NOT NULL,
    # total_male_applications_count integer DEFAULT 0 NOT NULL,
    # remote_id character varying,
    # permalink character varying,
    # type character varying(40),
    # aasm_state character varying,
    # tutor_role character varying,
    # description_str character varying(500)
    update_column :internship_offers, :title, :string, limit: 150
    update_column :internship_offers, :description, :string, limit: 500
    update_column :internship_offers, :tutor_name, :string, limit: 150
    update_column :internship_offers, :tutor_phone, :string, limit: 20
    update_column :internship_offers, :tutor_email, :string, limit: 100
    update_column :internship_offers, :employer_website, :string, limit: 250
    update_column :internship_offers, :street, :string, limit: 200
    update_column :internship_offers, :zipcode, :string, limit: 5
    update_column :internship_offers, :city, :string, limit: 50
    update_column :internship_offers, :employer_name, :string, limit: 150
    update_column :internship_offers, :employer_description, :string, limit: 250
    update_column :internship_offers, :employer_type, :string, limit: 30
    update_column :internship_offers, :department, :string, limit: 40
    update_column :internship_offers, :academy, :string, limit: 50
    update_column :internship_offers, :remote_id, :string, limit: 60
    update_column :internship_offers, :permalink, :string, limit: 200
    update_column :internship_offers, :aasm_state, :string, limit: 100
    update_column :internship_offers, :tutor_role, :string, limit: 150


    # operators (
    # name character varying,
    # logo character varying,
    # website character varying,
    update_column :operators, :name, :string, limit: 80
    update_column :operators, :logo, :string, limit: 250
    update_column :operators, :website, :string, limit: 250

    # organisations (
    # employer_name character varying NOT NULL,
    # street character varying NOT NULL,
    # zipcode character varying NOT NULL,
    # city character varying NOT NULL,
      # employer_website character varying(560),
    # department character varying DEFAULT ''::character varying NOT NULL,
    update_column :organisations, :employer_name, :string, limit: 150
    update_column :organisations, :street, :string, limit: 200
    update_column :organisations, :zipcode, :string, limit: 5
    update_column :organisations, :city, :string, limit: 50
    update_column :organisations, :department, :string, limit: 40

    # practical_infos (
    # street character varying NOT NULL,
    # zipcode character varying NOT NULL,
    # city character varying NOT NULL,
    # department character varying DEFAULT ''::character varying NOT NULL,
    update_column :practical_infos, :street, :string, limit: 470
    update_column :practical_infos, :zipcode, :string, limit: 5
    update_column :practical_infos, :city, :string, limit: 50
    update_column :practical_infos, :department, :string, limit: 40
    update_column :practical_infos, :contact_phone, :string, limit: 20

    # schools (
    # name character varying DEFAULT ''::character varying NOT NULL,
    # city character varying DEFAULT ''::character varying NOT NULL,
    # department character varying,
    # zipcode character varying,
    # code_uai character varying,
    # street character varying,
    # kind character varying,
    # legal_status character varying,
    update_column :schools, :name, :string, limit: 150
    update_column :schools, :city, :string, limit: 50
    update_column :schools, :department, :string, limit: 40
    update_column :schools, :zipcode, :string, limit: 5
    update_column :schools, :code_uai, :string, limit: 10
    update_column :schools, :street, :string, limit: 200
    update_column :schools, :kind, :string, limit: 50
    update_column :schools, :legal_status, :string, limit: 20

    # sectors (
    # name character varying,
    # external_url character varying DEFAULT ''::character varying NOT NULL,
    update_column :sectors, :name, :string, limit: 50
    update_column :sectors, :external_url, :string, limit:200

    # task_registers (
    # task_name character varying,
    # used_environment character varying,
    update_column :sectors, :name, :string, limit: 50
    update_column :sectors, :used_environment, :string, limit: 50

    # team_member_invitations (
    # aasm_state character varying DEFAULT 'pending_invitation'::character varying
    update_column :team_member_invitations, :invitation_email, :string, limit: 150
    update_column :team_member_invitations, :aasm_state, :string, limit: 100

    # tutors (
    # tutor_name character varying NOT NULL,
    # tutor_email character varying NOT NULL,
    # tutor_phone character varying NOT NULL,
    # tutor_role character varying
    update_column :tutors, :tutor_name, :string, limit: 120
    update_column :tutors, :tutor_email, :string, limit: 100
    update_column :tutors, :tutor_phone, :string, limit: 20
    update_column :tutors, :tutor_role, :string, limit: 250


    # url_shrinkers (
    # original_url character varying,
    # url_token character varying,
    update_column :url_shrinkers, :original_url, :string, limit: 370
    update_column :url_shrinkers, :url_token, :string, limit: 6;
  end
end