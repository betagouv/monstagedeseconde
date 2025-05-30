FactoryBot.define do
  factory :internship_agreement do
    internship_application { create(:weekly_internship_application) }

    school_representative_full_name { internship_application.student.school.school_manager&.presenter&.full_name }
    school_representative_phone { FFaker::PhoneNumberFR.mobile_phone_number }
    school_representative_email { FFaker::Internet.email }
    school_representative_role { 'Principal de lycée' }
    student_school { internship_application.student.school.name }
    student_address do
      "#{FFaker::Address.street_address} #{internship_application.student.school.zipcode} #{internship_application.student.school.city}"
    end
    student_refering_teacher_full_name { FFaker::NameFR.name }
    student_refering_teacher_email { FFaker::Internet.email }
    student_refering_teacher_phone { FFaker::PhoneNumberFR.mobile_phone_number }
    student_phone { '+330325254575' }
    siret { FFaker::CompanyFR.siret }
    student_full_name { internship_application.student.presenter.full_name }
    student_legal_representative_full_name { FFaker::NameFR.name }
    student_legal_representative_phone { FFaker::PhoneNumberFR.mobile_phone_number }
    student_legal_representative_email { FFaker::Internet.email }
    student_legal_representative_2_full_name { FFaker::NameFR.name }
    student_legal_representative_2_phone { FFaker::PhoneNumberFR.mobile_phone_number }
    student_legal_representative_2_email { FFaker::Internet.email }
    student_class_room { '2de A' }
    organisation_representative_full_name { 'DGSE' }
    tutor_role { 'Responsable financier' }
    tutor_full_name { FFaker::NameFR.name }
    tutor_email { FFaker::Internet.email }
    date_range { 'du 10/10/2020 au 15/10/2020' }
    activity_scope { 'Accueil clients' }
    activity_preparation { 'Appel téléphonique' }
    aasm_state { 'draft' }
    weekly_hours { ['9:00', '17:00'] }
    weekly_lunch_break { '1h dans la cantine. Repas fourni.' }
    activity_rating do
      "Après concertation, le tuteur appelera le professeur principal vers 17h le lundi et au moins un autre jour de la semaine choisi ensemble. L'élève n'est pas convié à cet échange.<br/>A ceci se rajoute le rapport de stage"
    end
    activity_learnings { 'Communication orale' }
    uuid { SecureRandom.uuid }

    before(:create) do |ia|
      academy_region = AcademyRegion.find_or_create_by(name: 'Ile-de-France')
      academy = Academy.find_or_create_by(name: 'Paris', email_domain: 'ac-paris.fr', academy_region:)
      department = Department.create(code: '75', name: 'Paris', academy:)
    end

    trait :created_by_system do
      skip_validations_for_system { true }
    end

    trait :draft do
      aasm_state { 'draft' }
    end
    trait :started_by_employer do
      aasm_state { 'started_by_employer' }
    end
    trait :completed_by_employer do
      aasm_state { 'completed_by_employer' }
    end
    trait :started_by_school_manager do
      aasm_state { 'started_by_school_manager' }
    end
    trait :validated do
      aasm_state { 'validated' }
    end
    trait :signatures_started do
      aasm_state { 'signatures_started' }
    end

    trait :signed_by_employer_only do
      aasm_state { 'signatures_started' }
      after(:create) do |ia|
        create(:signature,
               :employer,
               internship_agreement: ia,
               user_id: ia.employer.id)
      end
    end

    trait :signed_by_school_manager_only do
      aasm_state { 'signatures_started' }
      after(:create) do |ia|
        create(:signature,
               :school_manager,
               internship_agreement: ia,
               user_id: ia.school_manager.id)
      end
    end

    trait :signed_by_all do
      aasm_state { 'signed_by_all' }
      after(:create) do |ia|
        create(:signature,
               :employer,
               internship_agreement: ia,
               user_id: ia.employer.id)
        create(:signature,
               :school_manager,
               internship_agreement: ia,
               user_id: ia.school_manager.id)
      end
    end
  end
end
