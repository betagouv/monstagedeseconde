# frozen_string_literal: true

FactoryBot.define do
  factory :internship_application do
    student { create(:student_with_class_room_3e) }
    motivation_tmp { 'Suis hyper motivé' }
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
    end

    trait :submitted do
      aasm_state { :submitted }
      submitted_at { 3.days.ago }
    end

    trait :read_by_employer do
      aasm_state { :read_by_employer }
      submitted_at { 3.days.ago }
      read_at { 2.days.ago }
    end

    trait :expired do
      aasm_state { :expired }
      submitted_at { 19.days.ago }
      expired_at { 3.days.ago }
    end

    trait :validated_by_employer do
      aasm_state { :validated_by_employer }
      submitted_at { 15.days.ago }
      validated_by_employer_at { 2.days.ago }
    end

    trait :approved do
      aasm_state { :approved }
      submitted_at { 3.days.ago }
      validated_by_employer_at { 2.days.ago }
      approved_at { 1.days.ago }
      after(:create) do |internship_application|
        create(:internship_agreement, internship_application:)
      end
    end

    trait :rejected do
      aasm_state { :rejected }
      submitted_at { 3.days.ago }
      rejected_at { 2.days.ago }
    end

    trait :canceled_by_employer do
      aasm_state { :canceled_by_employer }
      submitted_at { 3.days.ago }
      rejected_at { 2.days.ago }
      canceled_at { 2.days.ago }
    end

    trait :canceled_by_student do
      aasm_state { :canceled_by_student }
      submitted_at { 3.days.ago }
      canceled_at { 2.days.ago }
    end

    trait :canceled_by_student_confirmation do
      aasm_state { :canceled_by_student_confirmation }
      submitted_at { 3.days.ago }
      validated_by_employer_at { 2.days.ago }
      approved_at { 1.days.ago }
    end

    trait :expired_by_student do
      aasm_state { :expired_by_student }
      submitted_at { 3.days.ago }
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
