# frozen_string_literal: true

FactoryBot.define do
  sequence(:phone) do |n|
    n.even? ? "+330637#{n.to_s.rjust(6, '0')}" : "+2620612#{n.to_s.rjust(6, '0')}"
  end
  factory :user do
    first_name { FFaker::NameFR.first_name.capitalize }
    last_name { FFaker::NameFR.last_name.capitalize }
    sequence(:email) { |n| "jean#{n}-claude@#{last_name}.fr" }
    password { 'ooooyeahhhh1Max!!' }
    confirmed_at { Time.now }
    confirmation_sent_at { Time.now }
    accept_terms { true }
    phone_token { nil }
    phone_token_validity { nil }
    phone_password_reset_count { 0 }
    last_phone_password_reset { 10.days.ago }
    grade_id { nil }

    # Student
    factory :student, class: 'Users::Student', parent: :user do
      ine { "1#{rand(10.pow(8))}#{('A'..'Z').to_a.sample}#{('A'..'Z').to_a.sample}" }
      type { 'Users::Student' }

      first_name { FFaker::NameFR.first_name.capitalize }
      last_name { FFaker::NameFR.last_name.capitalize }
      gender { %w[m f].sample }
      birth_date { 14.years.ago }
      school { create(:school, :with_school_manager) }
      address { FFaker::AddressFR.full_address }
      legal_representative_email { FFaker::Internet.email }
      legal_representative_full_name { FFaker::NameFR.name }
      legal_representative_phone { generate(:phone) }
      grade { Grade.troisieme }

      trait :male do
        gender { 'm' }
      end

      trait :when_applying do
        phone
      end

      trait :female do
        gender { 'f' }
      end

      trait :not_precised do
        gender { 'np' }
      end

      trait :registered_with_phone do
        email { nil }
        phone
      end

      trait :quatrieme do
        grade { Grade.quatrieme }
      end

      trait :troisieme do
        grade { Grade.troisieme }
      end

      trait :seconde do
        grade { Grade.seconde }
      end

      trait :with_phone do
        phone
      end

      factory :student_with_class_room_3e, class: 'Users::Student', parent: :student do
        class_room { create(:class_room, :troisieme) }
        after(:create) do |student|
          create(:main_teacher, class_room: student.class_room, school: student.school)
        end
        grade { Grade.troisieme }
      end

      factory :student_with_class_room_2nde, class: 'Users::Student', parent: :student do
        class_room { create(:class_room, :seconde) }
        after(:create) do |student|
          create(:main_teacher, class_room: student.class_room, school: student.school)
        end
        grade { Grade.seconde }
      end
    end

    # Employer
    factory :employer,
            class: 'Users::Employer',
            parent: :user do
      type { 'Users::Employer' }
      employer_role { 'PDG' }

      after(:create) do |employer|
        unless employer.current_area
          new_area = create(:internship_offer_area, employer:)
          employer.current_area = new_area
          employer.save
        end
      end
    end

    factory :god, class: 'Users::God', parent: :user do
      type { 'Users::God' }
    end

    factory :school_manager, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { Users::SchoolManagement.roles[:school_manager] }
      sequence(:email) { |n| "ce.#{'%07d' % n}#{('a'..'z').to_a.sample}@#{school.email_domain_name}" }

      after(:create) do |school_manager|
        # Ensure the school_manager is associated with the school
        school_manager.update!(school: school_manager.school)
        # Create UserSchool association
        UserSchool.create!(user: school_manager, school: school_manager.school) unless UserSchool.exists?(
          user: school_manager, school: school_manager.school
        )
      end
    end

    factory :main_teacher, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { 'main_teacher' }

      first_name { 'Madame' }
      last_name { 'Labutte' }

      sequence(:email) { |n| "labutte.#{n}@#{school.email_domain_name}" }
      after(:create) do |main_teacher|
        main_teacher.update!(school: main_teacher.school)
        UserSchool.create!(user: main_teacher, school: main_teacher.school) unless UserSchool.exists?(
          user: main_teacher, school: main_teacher.school
        )
      end
    end

    factory :teacher, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { 'teacher' }

      sequence(:email) { |n| "labotte.#{n}@#{school.email_domain_name}" }
      after(:create) do |teacher|
        teacher.update!(school: teacher.school)
        UserSchool.create!(user: teacher, school: teacher.school) unless UserSchool.exists?(
          user: teacher, school: teacher.school
        )
      end
    end

    factory :other, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { 'other' }

      sequence(:email) { |n| "lautre.#{n}@#{school.email_domain_name}" }
      after(:create) do |other|
        other.update!(school: other.school)
        UserSchool.create!(user: other, school: other.school) unless UserSchool.exists?(
          user: other, school: other.school
        )
      end
    end

    factory :admin_officer, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { 'admin_officer' }

      sequence(:email) { |n| "resp_admin.#{n}@#{school.email_domain_name}" }
      after(:create) do |admin_officer|
        admin_officer.update!(school: admin_officer.school)
        UserSchool.create!(user: admin_officer, school: admin_officer.school) unless UserSchool.exists?(
          user: admin_officer, school: admin_officer.school
        )
      end
    end

    factory :cpe, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { 'cpe' }

      sequence(:email) { |n| "cpe.#{n}@#{school.email_domain_name}" }
      after(:create) do |cpe|
        cpe.update!(school: cpe.school)
        UserSchool.create!(user: cpe, school: cpe.school) unless UserSchool.exists?(
          user: cpe, school: cpe.school
        )
      end
    end

    factory :statistician,
            class: 'Users::PrefectureStatistician',
            parent: :user do
      type { 'Users::PrefectureStatistician' }
      agreement_signatorable { true }
      department { '60' }
      statistician_validation { true }
    end

    factory :prefecture_statistician,
            class: 'Users::PrefectureStatistician',
            parent: :user do
      type { 'Users::PrefectureStatistician' }
      agreement_signatorable { false }
      department { '60' }
      statistician_validation { true }
      after(:create) do |employer|
        unless employer.current_area
          new_area = create(:internship_offer_area, employer:)
          employer.current_area = new_area
          employer.save
        end
      end
    end

    factory :education_statistician,
            parent: :user,
            class: 'Users::EducationStatistician' do
      type { 'Users::EducationStatistician' }
      agreement_signatorable { false }
      statistician_validation { true }
      department { '60' }
      after(:create) do |employer|
        unless employer.current_area
          new_area = create(:internship_offer_area, employer:)
          employer.current_area = new_area
          employer.save
        end
      end
    end

    factory :ministry_statistician,
            parent: :user,
            class: 'Users::MinistryStatistician' do
      type { 'Users::MinistryStatistician' }
      agreement_signatorable { false }
      statistician_validation { true }
      groups { [create(:group, is_public: true), create(:group, is_public: true)] }
      after(:create) do |employer|
        unless employer.current_area
          new_area = create(:internship_offer_area, employer:)
          employer.current_area = new_area
          employer.save
        end
      end
    end

    factory :academy_statistician,
            parent: :user,
            class: 'Users::AcademyStatistician' do
      type { 'Users::AcademyStatistician' }
      agreement_signatorable { false }
      statistician_validation { true }
      academy { create(:academy) }
    end

    factory :academy_region_statistician,
            parent: :user,
            class: 'Users::AcademyRegionStatistician' do
      type { 'Users::AcademyRegionStatistician' }
      agreement_signatorable { false }
      statistician_validation { true }
      academy_region { create(:academy_region) }
    end

    # user_operator gets its offer_area created by callback
    factory :user_operator,
            parent: :user,
            class: 'Users::Operator' do
      type { 'Users::Operator' }
      operator
      api_token { SecureRandom.uuid }

      trait :fully_authorized do
        after(:create) do |user|
          user.operator.update(api_full_access: true)
        end
      end
      after(:create) do |employer|
        unless employer.current_area
          new_area = create(:internship_offer_area, employer:)
          employer.current_area = new_area
          employer.save
        end
      end
    end

    #
    # Users::Student specific traits
    #
    # traits to create a student[with a school] having a specific class_rooms
    trait :troisieme_generale do
      class_room { build(:class_room, school:) }
    end
  end
end
