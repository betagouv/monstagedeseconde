def student_maker(school:, class_room:, grade: nil )
  first_name = FFaker::NameFR.first_name
  first_name = 'Kilian' if first_name.include?(' ')
  last_name = FFaker::NameFR.unique.last_name
  last_name = 'Ploquin' if last_name.include?(' ')
  grades = [Grade.troisieme, Grade.seconde]
  student_grade_id = grade.nil? ? ([Grade.seconde] * 4 + [Grade.troisieme] * 4).sample : grade.id
  email_domain = student_grade_id == Grade.troisieme.id ? 'ms3e.fr' : 'ms2e.fr'
  email = "#{first_name.gsub(/[éèê]/, 'e')}.#{last_name.gsub(/[éèê]/, 'e')}@#{email_domain}"
  Users::Student.new(
    ine: make_ine,
    first_name:,
    last_name:,
    email:,
    password: password_value,
    school:,
    grade_id: student_grade_id,
  )
end

def make_ine
  numbers = (0..9).to_a.sample(9).join
  letters = %w[A B C D E F G H J].sample(2).join
  "#{numbers}#{letters}"
end

def password_value
  ENV['DEFAULT_PASSWORD']
end

def random_class_room(type: :college)
  class_rooms = if type == :college
                  a_parisian_college.class_rooms
                else
                  a_parisian_lycee.class_rooms
                end
  class_rooms.sample
end

def populate_users
  # --- God ---
  random_extra_attributes(Users::God.new(email: 'god@ms2e.fr',
  password: password_value)).save!

  # --- Employers ---
  random_extra_attributes(
    Users::Employer.new(
      email: 'employer@ms2e.fr',
      password: password_value,
      employer_role: 'PDG',
      phone: '+330622554144'
    )
  ).save!

  random_extra_attributes(
    Users::Employer.new(
      email: 'other_employer@ms2e.fr',
      password: password_value,
      employer_role: 'PDG',
      phone: '+330622554145'
      )
      ).save!

  # --- SchoolManagement ---
  # --- SchoolManager ---
  users = []
  users << Users::SchoolManagement.new(
    role: 'school_manager',
    email: "ce.1234567X@#{a_parisian_lycee.email_domain_name}",
    password: password_value,
    school: a_parisian_lycee,
    phone: '+330623655541'
  )

  # --- SchoolManagement : other roles ---
  # -- seconde / lycée
  users << Users::SchoolManagement.new(
    role: 'main_teacher',
    class_room: a_parisian_lycee.class_rooms.first,
    email: "main_teacher_lycee@#{a_parisian_lycee.email_domain_name}",
    password: password_value,
    school: a_parisian_lycee
  )
    users << Users::SchoolManagement.new(
    role: 'other',
    email: "other_lycee@#{a_parisian_lycee.email_domain_name}",
    password: password_value,
    school: a_parisian_lycee
  )
  users << Users::SchoolManagement.new(
    role: 'teacher',
    class_room: a_parisian_lycee.class_rooms.second,
    email: "teacher_lycee@#{a_parisian_lycee.email_domain_name}",
    password: password_value,
    school: a_parisian_lycee
  )
  users << Users::SchoolManagement.new(
    role: 'cpe',
    email: "cpe_lycee@#{a_parisian_lycee.email_domain_name}",
    password: password_value,
    school: a_parisian_lycee
  )
  users << Users::SchoolManagement.new(
    role: 'admin_officer',
    email: "admin_officer_lycee@#{a_parisian_lycee.email_domain_name}",
    password: password_value,
    school: a_parisian_lycee
  )

  # -- troisieme / collège

  users << Users::SchoolManagement.new(
    role: 'school_manager',
    email: "ce.1234568X@#{a_parisian_college.email_domain_name}",
    password: password_value,
    school: a_parisian_college,
    phone: '+330623655547'
  )

  # --- SchoolManagement : other roles ---
  # -- seconde / lycée
  users << Users::SchoolManagement.new(
    role: 'main_teacher',
    class_room: a_parisian_college.class_rooms.first,
    email: "main_teacher_college@#{a_parisian_college.email_domain_name}",
    password: password_value,
    school: a_parisian_college
  )
  users << Users::SchoolManagement.new(
    role: 'other',
    email: "other_college@#{a_parisian_college.email_domain_name}",
    password: password_value,
    school: a_parisian_college
  )
  users << Users::SchoolManagement.new(
    role: 'teacher',
    class_room: a_parisian_college.class_rooms.second,
    email: "teacher_college@#{a_parisian_college.email_domain_name}",
    password: password_value,
    school: a_parisian_college
  )
  users << Users::SchoolManagement.new(
    role: 'cpe',
    email: "cpe_college@#{a_parisian_college.email_domain_name}",
    password: password_value,
    school: a_parisian_college
  )
  users << Users::SchoolManagement.new(
    role: 'admin_officer',
    email: "admin_officer_college@#{a_parisian_college.email_domain_name}",
    password: password_value,
    school: a_parisian_college
  )

  # --- Users::Operator ---
  Operator.all.map do |operator|
    users << Users::Operator.new(email: "#{operator.name.parameterize}@ms2e.fr",
    password: password_value,
    operator: operator)
  end
  users << Users::Operator.new(email: 'operator@ms2e.fr', password: password_value, operator: Operator.first)

  # --- Users::Statisticians ---
  statistician_email = 'statistician@ms2e.fr'
  ministry_statistician_email = 'ministry_statistician@ms2e.fr'
  education_statistician_email = 'education_statistician@ms2e.fr'
  academy_statistician_email = 'academy_statistician@ms2e.fr'
  academy_region_statistician_email = 'academy_region_statistician@ms2e.fr'
  last_public_groups = Group.where(is_public: true).last(2)

  users << Users::PrefectureStatistician.new(email: statistician_email, password: password_value, department: '60')
  users << Users::EducationStatistician.new(email: education_statistician_email, password: password_value, department: '60')
  users << Users::MinistryStatistician.new(email: ministry_statistician_email, password: password_value, groups: last_public_groups)
  users << Users::AcademyStatistician.new(email: academy_statistician_email, password: password_value, academy: Academy.first)
  users << Users::AcademyRegionStatistician.new(email: academy_region_statistician_email, password: password_value, academy_region: AcademyRegion.first)

  # --- saving
  users.each do |user|
    user = random_extra_attributes(user)
    user.save!
  end
end

def populate_students
  users = []
  lycee = a_parisian_lycee
  college = a_parisian_college
  class_rooms = lycee.class_rooms

  # Lycee students

  users << Users::Student.new(
    ine: make_ine,
    email: 'student@ms2e.fr',
    password: password_value,
    school: lycee,
    class_room: random_class_room(type: :lycee),
    grade: Grade.seconde
    )
  users << Users::Student.new(
    ine: make_ine,
    email: 'student_other@ms2e.fr',
    password: password_value,
    school: lycee,
    class_room: random_class_room(type: :lycee),
    grade: Grade.seconde
    )
  # sans classe
  users << Users::Student.new(
    ine: make_ine,
    email: 'enzo@ms2e.fr',
    password: password_value,
    first_name: 'Enzo',
    last_name: 'Clerc',
    school: lycee,
    gender: 'm',
    grade: Grade.seconde
  )

  3.times { users << student_maker(school: lycee, class_room: random_class_room(type: :lycee), grade: Grade.seconde) }

  users << Users::Student.new(
    ine: make_ine,
    email: 'louis@ms2e.fr',
    password: password_value,
    first_name: 'Louis',
    last_name: 'Tardieu',
    school: lycee,
    class_room: random_class_room(type: :lycee),
    grade: Grade.seconde
  )
  users << Users::Student.new(
    ine: make_ine,
    email: 'leon@ms2e.fr',
    password: password_value,
    first_name: 'Leon',
    last_name: 'Luanco',
    school: lycee,
    class_room: random_class_room(type: :lycee),
    gender: 'm',
    grade: Grade.seconde
  )
  2.times { users << student_maker(school: lycee, class_room: random_class_room(type: :lycee), grade: Grade.seconde) }

    # collèges
  7.times { users << student_maker(school: college, class_room: random_class_room(type: :college), grade: Grade.troisieme) }
  users << Users::Student.new(
    ine: make_ine,
    email: 'raphaelle@ms3e.fr',
    password: password_value,
    first_name: 'Raphaëlle',
    last_name: 'Mesnard',
    school: missing_school_manager_school,
    gender: 'f',
    school: college,
    class_room: random_class_room(type: :college),
    grade: Grade.troisieme
  )
  users << Users::Student.new(
    ine: make_ine,
    email: 'alexandrine@ms3e.fr',
    password: password_value,
    first_name: 'Alexandrine',
    last_name: 'Chotin',
    school: a_parisian_college,
    gender: 'f',
    school: college,
    class_room: random_class_room(type: :college),
    grade: Grade.troisieme
  )
  users << Users::Student.new(
    ine: make_ine,
    email: 'yvan@ms3e.fr',
    password: password_value,
    first_name: 'Yvan',
    last_name: 'Duhamel',
    school: a_parisian_college,
    gender: 'f',
    school: college,
    class_room: random_class_room(type: :college),
    grade: Grade.troisieme
  )

  # --- saving
  users.each do |user|
    user = random_extra_attributes(user)
    user.save!
  end
end

call_method_with_metrics_tracking(%i[
                                    populate_users
                                    populate_students
                                  ])
