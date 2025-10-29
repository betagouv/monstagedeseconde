module ReviewRebuild
  module StudentsCreationSteps
    extend ActiveSupport::Concern

    def colleges = [college_qpv, college_standard, college_rep]

    def choose_school(seconde, number)
      schools = [lycee_qpv, college_qpv, lycee_standard, college_standard, lycee_rep, college_rep]
      add_class_rooms_when_missing(schools)
      add_internship_weeks_when_missing
      school = nil
      case number.to_i
      when 1 # QPV
        school = seconde ? lycee_qpv : college_qpv
      when 2 # standard
        school = seconde ? lycee_standard : college_standard
      when 3 # REP
        school = seconde ? lycee_rep : college_rep
      else
        raise StandardError, 'Unknown school type'
      end
      raise StandardError, "School not found with uai_code: #{seconde}/#{number}" unless school

      school
    end

    def add_class_rooms_when_missing(schools)
      schools.each do |school|
        next if school.class_rooms.any?

        school_type = school.school_type
        if school_type == 'lycee'
          ClassRoom.find_or_create_by(school: school, name: '2de A', grade: Grade.seconde)
          ClassRoom.find_or_create_by(school: school, name: '2de B', grade: Grade.seconde)
        else
          ClassRoom.find_or_create_by(school: school, name: '3eme A', grade: Grade.troisieme)
          ClassRoom.find_or_create_by(school: school, name: '3eme B', grade: Grade.troisieme)
        end
      end
    end

    def add_internship_weeks_when_missing
      colleges.each do |college|
        next if college.weeks.any?

        college.weeks = SchoolTrack::Troisieme.selectable_from_now_until_end_of_school_year.last(3)
        college.save!
      end
    end

    def create_students
      # ---------------
      # 3eme
      # ---------------
      students_data = []

      students_data << { school_number: '1', email: 'eugenie.grandet@yahoo.com', gender: 'f', first_name: 'Eugénie',
                         last_name: 'Grandet', seconde: false }
      students_data << { school_number: '1', email: 'prince.lepetit@laposte.net', gender: 'np', first_name: 'Prince',
                         last_name: 'Lepetit', seconde: false }
      students_data << { school_number: '1', email: 'fabrice.deldongo@train-italia.it', gender: 'm',
                         first_name: 'Fabrice', last_name: 'DelDongo', seconde: false }
      students_data << { school_number: '1', email: 'sheherazade.shariar@alibaba.ir', gender: 'f',
                         first_name: 'Sheherazade', last_name: 'Shariar', seconde: false }
      students_data << { school_number: '1', email: 'edmond.dantes@france-plot.fr', gender: 'm', first_name: 'Edmond',
                         last_name: 'Dantès', seconde: false }
      students_data << { school_number: '1', email: 'marguerite.gauthier@interflora.fr', gender: 'f',
                         first_name: 'Marguerite', last_name: 'Gauthier', seconde: false }
      students_data << { school_number: '1', email: 'gilgamesh.uruk@transage.ir', gender: 'm',
                         first_name: 'Gilgamesh', last_name: 'Uruk', seconde: false }
      students_data << { school_number: '1', email: 'oliver.twist@educ.gov.uk', gender: 'm', first_name: 'Oliver',
                         last_name: 'Twist', seconde: false }
      students_data << { school_number: '1', email: 'jane.eyre@blind-light.com', gender: 'f', first_name: 'Jane',
                         last_name: 'Eyre', seconde: false }

      gmail_students_data_troisieme = []
      gmail_students_data_troisieme << { school_number: '1', first_name: 'Fabrice', last_name: 'Peutiot', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Amina', last_name: 'Souali', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '1', first_name: 'Theo', last_name: 'Caprizzi', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Sarah', last_name: 'Block', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '1', first_name: 'Hans', last_name: 'Schneider', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Benedicte', last_name: 'Luanco', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '1', first_name: 'Moussa', last_name: 'Diop', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Alissa', last_name: 'Diallo', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '1', first_name: 'Virgile', last_name: 'Racco', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Aïcha', last_name: 'Diago', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Edmond', last_name: 'Fabrice', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Louisa', last_name: 'Martin', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Khalil', last_name: 'Karoui', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Alice', last_name: 'Godichon', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Marius', last_name: 'Trevor', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Chloe', last_name: 'Mignon', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Valentin', last_name: 'Marcelin',
                                         gender: 'm' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Alissa', last_name: 'Karmina', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Isidore', last_name: 'Dupret', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Irma', last_name: 'Doucet', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '2', first_name: 'Patrice', last_name: 'Lemoine', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Veronique', last_name: 'Aldrich',
                                         gender: 'f' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Ursule', last_name: 'Tremoneau', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Ilam', last_name: 'Massima', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Mohsen', last_name: 'Mohammed', gender: 'm' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Lea', last_name: 'Vassoliakov', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Karl', last_name: 'Treventin', gender: 'm' }

      gmail_students_data_troisieme << { school_number: '3', first_name: 'Ali', last_name: 'Tordjman', gender: 'np' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Elsa', last_name: 'Duchemin', gender: 'np' }
      # to be anonymized
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Leax', last_name: 'Dridix', gender: 'f' }
      gmail_students_data_troisieme << { school_number: '3', first_name: 'Karlx', last_name: 'Treventinx', gender: 'm' }
      # ---------------
      # 2de
      # ---------------
      students_data << { school_number: '1', email: 'willy.wonka@haribo.com', gender: 'm', first_name: 'Willy',
                         last_name: 'Wonka', seconde: true }
      students_data << { school_number: '1', email: 'causette.tenardier@chanel.fr', gender: 'f', first_name: 'Causette',
                         last_name: 'Tenardier', seconde: true }
      students_data << { school_number: '1', email: 'harry.potter@paraquantique.org', gender: 'm', first_name: 'Harry',
                         last_name: 'Potter', seconde: true }
      students_data << { school_number: '1', email: 'anna.karenine@meetic.fr', gender: 'f', first_name: 'Anna',
                         last_name: 'Karenine', seconde: true }
      students_data << { school_number: '1', email: 'vernon.subutex@europhonics.uk', gender: 'm', first_name: 'Vernon',
                         last_name: 'Subutex', seconde: true }
      students_data << { school_number: '1', email: 'manon.lescaut@discover.fr', gender: 'f', first_name: 'Manon',
                         last_name: 'Lescaut', seconde: true }
      students_data << { school_number: '1', email: 'elisabeth.bennet@austin.eu', gender: 'f', first_name: 'Elizabeth',
                         last_name: 'Bennet', seconde: true }
      students_data << { school_number: '1', email: 'robinson.crusoe@lonely-planet.com', gender: 'm', first_name: 'Robinson',
                         last_name: 'Crusoe', seconde: true }

      gmail_students_data_seconde = []
      gmail_students_data_seconde << { school_number: '3', first_name: 'Nathalie', last_name: 'Sauvage', gender: 'f' }
      gmail_students_data_seconde << { school_number: '1', first_name: 'Amhmed', last_name: 'Moussa', gender: 'm' }
      gmail_students_data_seconde << { school_number: '1', first_name: 'Brigitte', last_name: 'Renaud', gender: 'f' }
      gmail_students_data_seconde << { school_number: '1', first_name: 'Paul', last_name: 'Beauvois', gender: 'm' }
      gmail_students_data_seconde << { school_number: '1', first_name: 'Celina', last_name: 'Alves', gender: 'f' }
      gmail_students_data_seconde << { school_number: '1', first_name: 'Michel', last_name: 'Palandin', gender: 'm' }
      gmail_students_data_seconde << { school_number: '1', first_name: 'Alizee', last_name: 'Martin', gender: 'f' }
      gmail_students_data_seconde << { school_number: '1', first_name: 'Patrick', last_name: 'Vasseur', gender: 'm' }
      gmail_students_data_seconde << { school_number: '1', first_name: 'Aline', last_name: 'Mazzeri', gender: 'f' }
      gmail_students_data_seconde << { school_number: '1', first_name: 'Emile', last_name: 'Grondin', gender: 'm' }
      gmail_students_data_seconde << { school_number: '2', first_name: 'Elvira', last_name: 'Gracheva', gender: 'f' }
      gmail_students_data_seconde << { school_number: '2', first_name: 'Maurice', last_name: 'Clement', gender: 'm' }
      gmail_students_data_seconde << { school_number: '2', first_name: 'Marthe', last_name: 'Humbert', gender: 'f' }
      gmail_students_data_seconde << { school_number: '2', first_name: 'Michel', last_name: 'Blin', gender: 'm' }
      gmail_students_data_seconde << { school_number: '2', first_name: 'Sylvie', last_name: 'Vallee', gender: 'f' }
      gmail_students_data_seconde << { school_number: '2', first_name: 'Hugues', last_name: 'Caron', gender: 'm' }
      gmail_students_data_seconde << { school_number: '2', first_name: 'Emmanuelle', last_name: 'Roche', gender: 'f' }
      gmail_students_data_seconde << { school_number: '2', first_name: 'David', last_name: 'Becker', gender: 'm' }
      gmail_students_data_seconde << { school_number: '2', first_name: 'Jeanne', last_name: 'Lopes', gender: 'f' }
      gmail_students_data_seconde << { school_number: '3', first_name: 'Olivier', last_name: 'Riviere', gender: 'm' }
      gmail_students_data_seconde << { school_number: '3', first_name: 'Elise', last_name: 'Michaud', gender: 'f' }
      gmail_students_data_seconde << { school_number: '3', first_name: 'Elie', last_name: 'Alves', gender: 'm' }
      gmail_students_data_seconde << { school_number: '3', first_name: 'Lorraine', last_name: 'Cordier', gender: 'f' }
      gmail_students_data_seconde << { school_number: '3', first_name: 'Charles', last_name: 'Regnier', gender: 'm' }
      gmail_students_data_seconde << { school_number: '3', first_name: 'Suzanne', last_name: 'Chretien', gender: 'f' }
      gmail_students_data_seconde << { school_number: '3', first_name: 'Leo', last_name: 'Deschamps', gender: 'm' }
      gmail_students_data_seconde << { school_number: '3',  first_name: 'Isabelle', last_name: 'Faure', gender: 'f' }
      gmail_students_data_seconde << { school_number: '3',  first_name: 'Edith', last_name: 'Fernandez', gender: 'f' }
      gmail_students_data_seconde << { school_number: '3',  first_name: 'Inès', last_name: 'Gomez', gender: 'f' }
      # to be anonymized
      gmail_students_data_seconde << { school_number: '3',  first_name: 'Inèsx', last_name: 'Gomezx', gender: 'f' }
      gmail_students_data_seconde << { school_number: '3', first_name: 'Leox', last_name: 'Deschampsx', gender: 'm' }

      students_data.each do |data|
        student = student_maker(**data)
        broadcast_error(student.errors.full_messages.to_sentence) if student.invalid?
        student.save!
      end

      gmail_students_data_seconde.each_with_index do |data, index|
        data.merge!(seconde: true)
        student = gmail_student_maker(**data)
        broadcast_error(student.errors.full_messages.to_sentence) if student.invalid?
        student.save!
        student.update_columns(confirmed_at: nil) if index < 2
      end
      Users::Student.last(2).each { |student| student.anonymize(send_email: false) }

      gmail_students_data_troisieme.each_with_index do |data, index|
        data.merge!(seconde: false)
        student = gmail_student_maker(**data)
        broadcast_error(student.errors.full_messages.to_sentence) if student.invalid?
        student.save!
        student.update_columns(confirmed_at: nil) if index < 2
      end
      Users::Student.last(2).each { |student| student.anonymize(send_email: false) }
    end

    def create_users_school_management
      school_management_data = []
      school_management_data << { school: lycee_qpv, first_name: 'Jean', last_name: 'Rossano',
                                  email: "ce.#{lycee_qpv.code_uai}@ac-paris.fr", role: 'school_manager' }
      school_management_data << { school: college_qpv, first_name: 'Bernard', last_name: 'Lacorre',
                                  email: "ce.#{college_qpv.code_uai}@ac-paris.fr", role: 'school_manager' }
      school_management_data << { school: lycee_standard, first_name: 'Wladimira', last_name: 'Koliakov',
                                  email: "ce.#{lycee_standard.code_uai}@ac-paris.fr", role: 'school_manager' }
      school_management_data << { school: college_standard, first_name: 'Jean', last_name: 'Bonnie',
                                  email: "ce.#{college_standard.code_uai}@ac-paris.fr", role: 'school_manager' }
      school_management_data << { school: lycee_rep, first_name: 'Simone', last_name: 'Clairoin',
                                  email: "ce.#{lycee_rep.code_uai}@ac-orleans-tours.fr", role: 'school_manager' }
      school_management_data << { school: college_rep, first_name: 'Philippe', last_name: 'Rapidel',
                                  email: "ce.#{college_rep.code_uai}@ac-orleans-tours.fr", role: 'school_manager' }
      # ---
      # roles.each { |role| schools.each { |school| puts "school_management_data << {school: #{school}, first_name: '#{FFaker::NameFR.first_name}', last_name:'#{FFaker::NameFR.last_name}', email: '#{FFaker::Internet.email}', role: '#{role}'}"}}
      school_management_data << { school: lycee_qpv, first_name: 'Cécile', last_name: 'Lagarde',
                                  email: 'rochel_hermiston@beatty.name', role: 'teacher' }
      school_management_data << { school: college_qpv, first_name: 'Jérôme', last_name: 'Gay', email: 'micah@daniel.ca',
                                  role: 'teacher' }
      school_management_data << { school: lycee_standard, first_name: 'Bertrand', last_name: 'Lemaire',
                                  email: 'leia_rolfson@gaylord.us', role: 'teacher' }
      school_management_data << { school: college_standard, first_name: 'Laure', last_name: 'Dupont',
                                  email: 'kourtney_vonrueden@blanda.us', role: 'teacher' }
      school_management_data << { school: lycee_rep, first_name: 'Océane', last_name: 'Denis',
                                  email: 'august.pfannerstill@hackett.ca', role: 'teacher' }
      school_management_data << { school: college_rep, first_name: 'Andrée', last_name: 'Faivre', email: 'emmie@moen.name',
                                  role: 'teacher' }
      school_management_data << { school: lycee_qpv, first_name: 'Thérèse', last_name: 'Clerc', email: 'carmelita@morar.com',
                                  role: 'cpe' }
      school_management_data << { school: college_qpv, first_name: 'Véronique', last_name: 'Rodriguez',
                                  email: 'shawnta@cremin.co.uk', role: 'cpe' }
      school_management_data << { school: lycee_standard, first_name: 'Jacques', last_name: 'Langlois',
                                  email: 'lan@treutel.biz', role: 'cpe' }
      school_management_data << { school: college_standard, first_name: 'daisy', last_name: 'Hamon',
                                  email: 'carroll.flatley@predovic.ca', role: 'cpe' }
      school_management_data << { school: lycee_rep, first_name: 'Thibaut', last_name: 'Gros',
                                  email: 'ned.rowe@dubuquebruen.us', role: 'cpe' }
      school_management_data << { school: college_rep, first_name: 'Benoît', last_name: 'Neveu', email: 'patience@sauer.biz',
                                  role: 'cpe' }
      school_management_data << { school: lycee_qpv, first_name: 'Olivier', last_name: 'Tessier', email: 'fredia@bernier.name',
                                  role: 'other' }
      school_management_data << { school: college_qpv, first_name: 'Valérie', last_name: 'Lemaitre',
                                  email: 'travis_kris@feil.biz', role: 'other' }
      school_management_data << { school: lycee_standard, first_name: 'Martin', last_name: 'Riviere',
                                  email: 'margene_murphy@kessler.com', role: 'other' }
      school_management_data << { school: college_standard, first_name: 'Véronique', last_name: 'Bourdon',
                                  email: 'theresa.olson@cremin.us', role: 'other' }
      school_management_data << { school: lycee_rep, first_name: 'Stéphanie', last_name: 'Lecomte',
                                  email: 'giselle.mclaughlin@durgan.us', role: 'other' }
      school_management_data << { school: college_rep, first_name: 'Nath', last_name: 'Costa', email: 'nickolas@bayer.name',
                                  role: 'other' }
      school_management_data << { school: lycee_qpv, first_name: 'Frédéric', last_name: 'Gall',
                                  email: 'roderick@reingermann.ca', role: 'admin_officer' }
      school_management_data << { school: college_qpv, first_name: 'Claire', last_name: 'Leblanc',
                                  email: 'annmarie@ortizlind.us', role: 'admin_officer' }
      school_management_data << { school: lycee_standard, first_name: 'Christophe', last_name: 'De',
                                  email: 'kendall@murazikeffertz.us', role: 'admin_officer' }
      school_management_data << { school: college_standard, first_name: 'Roland', last_name: 'Dijoux',
                                  email: 'hilaria.kovacek@emmerich.ca', role: 'admin_officer' }
      school_management_data << { school: lycee_rep, first_name: 'Clémence', last_name: 'Roussel',
                                  email: 'humberto@schimmelmohr.biz', role: 'admin_officer' }
      school_management_data << { school: college_rep, first_name: 'Marc', last_name: 'Guillaume',
                                  email: 'lionel_murphy@damore.info', role: 'admin_officer' }
      school_management_data.each do |data|
        school_management_user = Users::SchoolManagement.new(**data)
        school_management_user.accept_terms = true
        school_management_user.password = default_password
        school_management_user.confirmed_at = (1..24).to_a.sample.hours.ago
        school_management_user.current_sign_in_at = (2..5).to_a.sample.days.ago
        school_management_user.last_sign_in_at = (12..16).to_a.sample.days.ago
        broadcast_error(school_management_user.errors.full_messages.to_sentence) if school_management_user.invalid?
        school_management_user.save!
      end
    end

    # -- helpers

    def student_maker(email:, gender:, first_name:, last_name:, school_number:, seconde: true, confirmed: true)
      current_count = Users::Student.all.reload.count
      Users::Student.new.tap do |student|
        student.first_name = first_name
        student.last_name = last_name
        emails_part = email.split('@')
        student.email = "#{emails_part[0]}_#{seconde ? '2e' : '3e'}@#{emails_part[1]}"
        student.gender = gender
        student.ine = ine[current_count]
        student.phone = phone_store[current_count]
        student.grade = seconde ? Grade.seconde : Grade.troisieme
        student.school = choose_school(seconde, school_number)
        student.skip_callback_with_review_rebuild = true
        raise StandardError, "School not found for student #{student.school}" unless student.school

        student.birth_date ||= (seconde ? 14 : 15).years.ago + rand(1..12).days
        student.class_room = student.school.class_rooms.sample
        student.accept_terms = true
        student.password = default_password
        student.confirmed_at = confirmed ? (1..24).to_a.sample.hours.ago : nil
        student.current_sign_in_at = (2..5).to_a.sample.days.ago
        student.last_sign_in_at = (12..16).to_a.sample.days.ago
        # random_extra_attributes(student, seconde, confirmed)
      end
    end

    def gmail_student_maker(first_name:, last_name:, gender:, school_number:, seconde: true, confirmed: true)
      email = "#{first_name.downcase.strip}.#{last_name.downcase.strip}@gmail.com"
      student_maker(email: email, gender: gender, first_name: first_name, last_name: last_name,
                    school_number: school_number, seconde: seconde)
    end

    def random_extra_attributes(object, seconde, confirmed)
      return object if object.persisted?

      object.birth_date ||= (seconde ? 14 : 15).years.ago + rand(1..12).days
      raise StandardError, "School not found for student #{object.school}" unless object.school
      raise StandardError, "Class rooms not found for student #{object.school}" unless object.school.class_rooms.any?

      object.class_room = object.school.class_rooms.sample
      add_mandatory_attributes(object)
    end

    def add_mandatory_attributes(object)
      object.accept_terms = true
      object.password = default_password
      object.confirmed_at = confirmed ? (1..24).to_a.sample.hours.ago : nil
      object.current_sign_in_at = (2..5).to_a.sample.days.ago
      object.last_sign_in_at = (12..16).to_a.sample.days.ago
      object
    end

    # def geo_point_factory_array(coordinates_as_array)
    #   type = { geo_type: 'point' }
    #   factory = RGeo::ActiveRecord::SpatialFactoryStore.instance
    #                                                    .factory(type)
    #   factory.point(*coordinates_as_array)
    # end

    def uai_code_lycee_qpv        = '0754030Y'
    def uai_code_college_qpv      = '0752694W'
    def uai_code_lycee_standard   = '0371418R'
    def uai_code_college_standard = '0370764E'
    def uai_code_lycee_rep        = '0755709Y'
    def uai_code_college_rep      = '0370791J'

    def lycee_qpv        = School.find_by(code_uai: uai_code_lycee_qpv)
    def college_qpv      = School.find_by(code_uai: uai_code_college_qpv)
    def lycee_standard   = School.find_by(code_uai: uai_code_lycee_standard)
    def college_standard = School.find_by(code_uai: uai_code_college_standard)
    def lycee_rep        = School.find_by(code_uai: uai_code_lycee_rep)
    def college_rep      = School.find_by(code_uai: uai_code_college_rep)

    def lycee_qpv_students        = Users::Student.where(school: lycee_qpv).order(id: :desc).to_a
    def college_qpv_students      = Users::Student.where(school: college_qpv).order(id: :desc).to_a
    def lycee_standard_students   = Users::Student.where(school: lycee_standard).order(id: :desc).to_a
    def college_standard_students = Users::Student.where(school: college_standard).order(id: :desc).to_a
    def lycee_rep_students        = Users::Student.where(school: lycee_rep).order(id: :desc).to_a
    def college_rep_students      = Users::Student.where(school: college_rep).order(id: :desc).to_a

    def ine
      %w[
        621589743ON
        316945287JG
        587914263OE
        819632745GL
        321869457LR
        637215948YV
        573246891PN
        163972845NS
        973154268DN
        314597268IS
        546978231ES
        792416385RL
        981726453SI
        621580743ON
        316940287JG
        587910263OE
        819630745GL
        321860457LR
        637210948YV
        573240891PN
        163970845NS
        973150268DN
        314590268IS
        546970231ES
        792410385RL
        981720453SI
        601589743ON
        306945287JG
        507914263OE
        809632745GL
        301869457LR
        607215948YV
        503246891PN
        103972845NS
        903154268DN
        304597268IS
        506978231ES
        702416385RL
        901726453SI
        620589743ON
        310945287JG
        580914263OE
        810632745GL
        320869457LR
        630215948YV
        570246891PN
        160972845NS
        970154268DN
        310597268IS
        540978231ES
        790416385RL
        980726453SI
        621089743ON
        316045287JG
        587014263OE
        819032745GL
        321069457LR
        637015948YV
        573046891PN
        163072845NS
        973054268DN
        314097268IS
        546078231ES
        792016385RL
        981026453SI
        621509743ON
        316905287JG
        587904263OE
        819602745GL
        321809457LR
        637205948YV
        573206891PN
        163902845NS
        973104268DN
        314507268IS
        546908231ES
        792406385RL
        981706453SI
        621589740ON
        316945280JG
        587914260OE
        819632740GL
        321869450LR
        637215940YV
        573246890PN
        163972840NS
        973154260DN
        314597260IS
        546978230ES
        792416380RL
        981726450SI
      ]
    end

    def phone_store
      %w[
        +330612345679
        +330712345678
        +330687654321
        +330787654321
        +330703133675
        +330652557390
        +330686291959
        +330647296336
        +330682440692
        +330781469968
        +330703667843
        +330707081009
        +330675906684
        +330707001810
        +330741085917
        +330630720854
        +330756154911
        +330791151063
        +330615267668
        +330772308526
        +330768257882
        +330755883346
        +330782880601
        +330680404693
        +330677791694
        +330739436002
        +330688074456
        +330691480692
        +330753180305
        +330722208948
        +330667325385
        +330734974275
        +330664187089
        +330790525641
        +330713392169
        +330661232159
        +330761444357
        +330759165295
        +330787525453
        +330725120084
        +330735573603
        +330796935923
        +330655334549
        +330677073618
        +330781702423
        +330791876321
        +330718326575
        +330610956821
        +330709624767
        +330722121993
        +330760093589
        +330634927456
        +330788978069
        +330793793041
        +330608276427
        +330622602747
        +330738022669
        +330764774142
        +330776365056
        +330631517067
        +330718656272
        +330646060217
        +330786728621
        +330773548913
        +330650602938
        +330764550183
        +330605743256
        +330758183201
        +330611707824
        +330776788980
        +330719063949
        +330760297001
        +330718217479
        +330655585567
        +330740851081
        +330779163294
        +330618916801
        +330725741668
        +330764376233
      ]
    end
  end
end
