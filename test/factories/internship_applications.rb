# frozen_string_literal: true

FactoryBot.define do
  factory :internship_application do
    student { create(:student_with_class_room_3e) }
    motivation { 'Suis hyper motivé' }
    student_phone { "+330#{rand(6..7)}#{FFaker::PhoneNumberFR.mobile_phone_number[2..-1]}".gsub(' ', '') }
    student_email { FFaker::Internet.email }
    access_token { nil }
    student_address { FFaker::AddressFR.full_address }
    student_legal_representative_full_name { FFaker::NameFR.name }
    student_legal_representative_email { FFaker::Internet.email }
    student_legal_representative_phone do
      "+330#{rand(6..7)}#{FFaker::PhoneNumberFR.mobile_phone_number[2..-1]}".gsub(' ', '')
    end

    trait :drafted do
      aasm_state { :drafted }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: nil,
               to_state: 'drafted',
               author: application.student)
      end
    end

    trait :submitted do
      aasm_state { :submitted }
      submitted_at { 3.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'drafted',
               to_state: 'submitted',
               author: application.student)
      end
    end

    trait :read_by_employer do
      aasm_state { :read_by_employer }
      submitted_at { 3.days.ago }
      read_at { 2.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'submitted',
               to_state: 'read_by_employer',
               author: application.internship_offer.employer)
      end
    end

    trait :expired do
      aasm_state { :expired }
      submitted_at { 19.days.ago }
      expired_at { 3.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'submitted',
               to_state: 'expired',
               author: application.internship_offer.employer)
      end
    end

    trait :validated_by_employer do
      aasm_state { :validated_by_employer }
      submitted_at { 15.days.ago }
      validated_by_employer_at { 2.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'read_by_employer',
               to_state: 'validated_by_employer',
               author: application.internship_offer.employer)
      end
    end

    trait :approved do
      aasm_state { :approved }
      submitted_at { 3.days.ago }
      validated_by_employer_at { 2.days.ago }
      approved_at { 1.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'validated_by_employer',
               to_state: 'approved',
               author: application.internship_offer.employer)
        create(:internship_agreement, internship_application: application)
      end
    end

    trait :rejected do
      aasm_state { :rejected }
      submitted_at { 3.days.ago }
      rejected_at { 2.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'read_by_employer',
               to_state: 'rejected',
               author: application.internship_offer.employer)
      end
    end

    trait :canceled_by_employer do
      aasm_state { :canceled_by_employer }
      submitted_at { 3.days.ago }
      rejected_at { 2.days.ago }
      canceled_at { 2.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'approved',
               to_state: 'canceled_by_employer',
               author: application.internship_offer.employer)
      end
    end

    trait :canceled_by_student do
      aasm_state { :canceled_by_student }
      submitted_at { 3.days.ago }
      canceled_at { 2.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'approved',
               to_state: 'canceled_by_student',
               author: application.student)
      end
    end

    trait :canceled_by_student_confirmation do
      aasm_state { :canceled_by_student_confirmation }
      submitted_at { 3.days.ago }
      validated_by_employer_at { 2.days.ago }
      approved_at { 1.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'approved',
               to_state: 'canceled_by_student_confirmation',
               author: application.student)
      end
    end

    trait :expired_by_student do
      aasm_state { :expired_by_student }
      submitted_at { 3.days.ago }
      after(:create) do |application|
        create(:internship_application_state_change,
               internship_application: application,
               from_state: 'approved',
               to_state: 'expired_by_student',
               author: application.student)
      end
    end

    transient do
      weekly_internship_offer_helper { create(:weekly_internship_offer) }
    end

    trait :weekly do
      internship_offer { weekly_internship_offer_helper }
    end

    factory :weekly_internship_application, traits: [:weekly],
                                            parent: :internship_application,
                                            class: 'InternshipApplications::WeeklyFramed'
  end
end
