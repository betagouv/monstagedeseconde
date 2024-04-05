def student_maker (school: ,class_room: )
  first_name = FFaker::NameFR.first_name
  first_name = 'Kilian' if first_name.include?(' ')
  last_name = FFaker::NameFR.unique.last_name
  last_name = 'Ploquin' if last_name.include?(' ')
  email = "#{first_name.gsub(/[éèê]/,'e')}.#{last_name.gsub(/[éèê]/,'e')}@ms2e.fr"
  Users::Student.new(
    first_name: first_name,
    last_name: last_name,
    email: email,
    password: password_value,
    school: school,
    birth_date: 14.years.ago,
    gender: (['m']*4 + ['f']*4 + ['np']).shuffle.first,
    confirmed_at: 2.days.ago,
    class_room: class_room
  )
end

def password_value
  ENV['DEFAULT_PASSWORD']
end

def populate_users
  class_room = ClassRoom.first

  with_class_name_for_defaults(
    Users::Employer.new(
      email: 'employer@ms2e.fr',
      password: password_value,
      employer_role: 'PDG',
      phone: '+330622554144'
    )
  ).save!

  with_class_name_for_defaults(
    Users::Employer.new(
      email: 'other_employer@ms2e.fr',
      password: password_value,
      employer_role: 'PDG',
      phone: '+330622554145'
    )
  ).save!

  with_class_name_for_defaults(Users::God.new(email: 'god@ms2e.fr', password: password_value)).save!

  school_manager = with_class_name_for_defaults(Users::SchoolManagement.new(
    role: 'school_manager',
    email: "ce.1234567X@#{find_default_school_during_test.email_domain_name}",
    password: password_value,
    school: find_default_school_during_test,
    phone: '+330623655541'))
  school_manager.save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'main_teacher', class_room: class_room, email: "main_teacher@#{find_default_school_during_test.email_domain_name}", password: password_value, school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'main_teacher', email: "main_teacher_no_class_room@#{find_default_school_during_test.email_domain_name}", password: password_value, school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'other', email: "other@#{find_default_school_during_test.email_domain_name}", password: password_value, school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'teacher', email: "teacher@#{find_default_school_during_test.email_domain_name}", password: password_value, school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'cpe', email: "cpe@#{find_default_school_during_test.email_domain_name}", password: password_value, school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'admin_officer', email: "admin_officer@#{find_default_school_during_test.email_domain_name}", password: password_value, school: find_default_school_during_test)).save!

  Operator.all.map do |operator|
    with_class_name_for_defaults(Users::Operator.new(email: "#{operator.name.parameterize}@ms2e.fr", password: password_value, operator: operator)).save!
  end
  puts 'Operator.all.map done!'
  
  with_class_name_for_defaults(Users::Operator.new(email: 'operator@ms2e.fr', password: password_value, operator: Operator.first)).save!

  statistician_email = 'statistician@ms2e.fr'
  ministry_statistician_email = 'ministry_statistician@ms2e.fr'
  education_statistician_email = 'education_statistician@ms2e.fr'
  academy_statistician_email = 'academy_statistician@ms2e.fr'
  academy_region_statistician_email = 'academy_region_statistician@ms2e.fr'
  last_public_groups = Group.where(is_public: true).last(2)
  with_class_name_for_defaults(Users::PrefectureStatistician.new(email: statistician_email, password: password_value, department: '60')).save!
  with_class_name_for_defaults(Users::EducationStatistician.new(email: education_statistician_email, password: password_value,department: '60')).save!
  with_class_name_for_defaults(Users::MinistryStatistician.new(email: ministry_statistician_email, password: password_value, groups: last_public_groups)).save!
  with_class_name_for_defaults(Users::AcademyStatistician.new(email: academy_statistician_email, password: password_value, academy: Academy.first)).save!
  with_class_name_for_defaults(Users::AcademyRegionStatistician.new(email: academy_region_statistician_email, password: password_value, academy_region: AcademyRegion.first)).save!
end

def populate_students
  class_room_1 = ClassRoom.first
  class_room_2 = ClassRoom.second
  class_room_3 = ClassRoom.third

  school = class_room_1.school

  with_class_name_for_defaults(Users::Student.new(email: 'student@ms2e.fr',       password: password_value, first_name: 'Abdelaziz', last_name: 'Benzedine', school: find_default_school_during_test, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'student_other@ms2e.fr', password: password_value, first_name: 'Mohammed', last_name: 'Rivière', school: find_default_school_during_test, class_room: ClassRoom.first, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago)).save!
  # sans classe
  with_class_name_for_defaults(Users::Student.new(email: 'enzo@ms2e.fr', password: password_value, first_name: 'Enzo', last_name: 'Clerc', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 3.days.ago)).save!

  5.times { with_class_name_for_defaults(student_maker(school: school, class_room: class_room_1)).save! }

  2.times { with_class_name_for_defaults(student_maker(school: school, class_room: class_room_2)).save! }
  with_class_name_for_defaults(Users::Student.new(email: 'louis@ms2e.fr', password: password_value, first_name: 'Louis', last_name: 'Tardieu', school: school, birth_date: 14.years.ago, gender: 'np', confirmed_at: 2.days.ago, class_room: class_room_2)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'leon@ms2e.fr', password: password_value, first_name: 'Leon', last_name: 'Luanco', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_2)).save!

  2.times { with_class_name_for_defaults(student_maker(school: school, class_room: class_room_3)).save! }
  with_class_name_for_defaults(Users::Student.new(email: 'raphaelle@ms2e.fr', password: password_value,first_name: 'Raphaëlle', last_name: 'Mesnard',  school: missing_school_manager_school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_3)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'alexandrine@ms2e.fr', password: password_value, first_name: 'Alexandrine', last_name: 'Chotin',  school: missing_school_manager_school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_3)).save!
end

call_method_with_metrics_tracking([
  :populate_users,
  :populate_students
])
