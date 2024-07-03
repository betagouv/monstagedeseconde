class UpdateVarcharFieldsLenghtWhenMissing < ActiveRecord::Migration[7.1]
  def up
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
        change_column :internship_agreements, :date_range, :string, limit: 210
        change_column :internship_agreements, :organisation_representative_full_name, :string, limit: 100
        change_column :internship_agreements, :student_full_name, :string, limit: 100
        change_column :internship_agreements, :student_class_room, :string, limit: 50
        change_column :internship_agreements, :tutor_full_name, :string, limit: 275

        # identities (
        # first_name character varying,
        # last_name character varying,
        # gender character varying DEFAULT 'np'::character varying,
        # token character varying,
          # first_name character varying(82),
          # last_name character varying(82),
        change_column :identities, :first_name, :string, limit: 82
        change_column :identities, :last_name, :string, limit: 82

        # academies (
        # name character varying,
        # email_domain character varying,
        change_column :academies, :name, :string, limit: 40
        change_column :academies, :email_domain, :string, limit: 100

        # academy_regions (
        # name character varying,
        change_column :academy_regions, :name, :string, limit: 40

        # class_rooms (
        # name character varying,
        change_column :class_rooms, :name, :string, limit: 40

        # crafts (
        # number character varying NOT NULL,
        change_column :crafts, :number, :string, limit: 5

        # departments (
        # code character varying,
        # name character varying,
        change_column :departments, :code, :string, limit: 5
        change_column :departments, :name, :string, limit: 40

        # detailed_crafts (
        # number character varying NOT NULL,
        change_column :detailed_crafts, :name, :string, limit: 120

        # groups (
        # name character varying,
        change_column :groups, :name, :string, limit: 150

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
        change_column :internship_applications, :aasm_state, :string, limit: 100
        change_column :internship_applications, :type, :string, limit: 100
        change_column :internship_applications, :applicable_type, :string, limit: 100
        change_column :internship_applications, :student_phone, :string, limit: 20
        change_column :internship_applications, :student_email, :string, limit: 100
        change_column :internship_applications, :access_token, :string, limit: 20
        change_column :internship_applications, :student_address, :string, limit: 300

        # internship_offer_areas (
        # employer_type character varying,
        # name character varying,
        change_column :internship_offer_areas, :employer_type, :string, limit: 50
        change_column :internship_offer_areas, :name, :string, limit: 150

        # internship_offer_infos (
        # title character varying,
        # type character varying,
        change_column :internship_offer_infos, :title, :string, limit: 150
        change_column :internship_offer_infos, :type, :string, limit: 50

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
        change_column :internship_offers, :title, :string, limit: 150
        change_column :internship_offers, :description, :string, limit: 500
        change_column :internship_offers, :tutor_name, :string, limit: 150
        change_column :internship_offers, :tutor_phone, :string, limit: 20
        change_column :internship_offers, :tutor_email, :string, limit: 100
        change_column :internship_offers, :employer_website, :string, limit: 250
        change_column :internship_offers, :street, :string, limit: 200
        change_column :internship_offers, :zipcode, :string, limit: 5
        change_column :internship_offers, :city, :string, limit: 50
        change_column :internship_offers, :employer_name, :string, limit: 150
        change_column :internship_offers, :employer_description, :string, limit: 250
        change_column :internship_offers, :employer_type, :string, limit: 30
        change_column :internship_offers, :department, :string, limit: 40
        change_column :internship_offers, :academy, :string, limit: 50
        change_column :internship_offers, :remote_id, :string, limit: 60
        change_column :internship_offers, :permalink, :string, limit: 200
        change_column :internship_offers, :aasm_state, :string, limit: 100
        change_column :internship_offers, :tutor_role, :string, limit: 150


        # operators (
        # name character varying,
        # logo character varying,
        # website character varying,
        change_column :operators, :name, :string, limit: 80
        change_column :operators, :logo, :string, limit: 250
        change_column :operators, :website, :string, limit: 250

        # organisations (
        # employer_name character varying NOT NULL,
        # street character varying NOT NULL,
        # zipcode character varying NOT NULL,
        # city character varying NOT NULL,
          # employer_website character varying(560),
        # department character varying DEFAULT ''::character varying NOT NULL,
        change_column :organisations, :employer_name, :string, limit: 150
        change_column :organisations, :street, :string, limit: 200
        change_column :organisations, :zipcode, :string, limit: 5
        change_column :organisations, :city, :string, limit: 50
        change_column :organisations, :department, :string, limit: 40

        # practical_infos (
        # street character varying NOT NULL,
        # zipcode character varying NOT NULL,
        # city character varying NOT NULL,
        # department character varying DEFAULT ''::character varying NOT NULL,
        change_column :practical_infos, :street, :string, limit: 470
        change_column :practical_infos, :zipcode, :string, limit: 5
        change_column :practical_infos, :city, :string, limit: 50
        change_column :practical_infos, :department, :string, limit: 40
        change_column :practical_infos, :contact_phone, :string, limit: 20

        # schools (
        # name character varying DEFAULT ''::character varying NOT NULL,
        # city character varying DEFAULT ''::character varying NOT NULL,
        # department character varying,
        # zipcode character varying,
        # code_uai character varying,
        # street character varying,
        # kind character varying,
        # legal_status character varying,
        change_column :schools, :name, :string, limit: 150
        change_column :schools, :city, :string, limit: 50
        change_column :schools, :department, :string, limit: 40
        change_column :schools, :zipcode, :string, limit: 5
        change_column :schools, :code_uai, :string, limit: 10
        change_column :schools, :street, :string, limit: 200
        change_column :schools, :kind, :string, limit: 50
        change_column :schools, :legal_status, :string, limit: 20

        # sectors (
        # name character varying,
        # external_url character varying DEFAULT ''::character varying NOT NULL,
        change_column :sectors, :name, :string, limit: 50
        change_column :sectors, :external_url, :string, limit:200

        # task_registers (
        # task_name character varying,
        # used_environment character varying,
        change_column :sectors, :name, :string, limit: 50
        change_column :sectors, :uuid, :string, limit: 50
        change_column :sectors, :external_url, :string, limit: 300

        # team_member_invitations (
        # aasm_state character varying DEFAULT 'pending_invitation'::character varying
        change_column :team_member_invitations, :invitation_email, :string, limit: 150
        change_column :team_member_invitations, :aasm_state, :string, limit: 100

        # tutors (
        # tutor_name character varying NOT NULL,
        # tutor_email character varying NOT NULL,
        # tutor_phone character varying NOT NULL,
        # tutor_role character varying
        change_column :tutors, :tutor_name, :string, limit: 120
        change_column :tutors, :tutor_email, :string, limit: 100
        change_column :tutors, :tutor_phone, :string, limit: 20
        change_column :tutors, :tutor_role, :string, limit: 250


        # url_shrinkers (
        # original_url character varying,
        # url_token character varying,
        change_column :url_shrinkers, :original_url, :string, limit: 370
        change_column :url_shrinkers, :url_token, :string, limit: 6
  end

  def down
  end
end
