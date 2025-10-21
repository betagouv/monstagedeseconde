FactoryBot.define do
  factory :signature do
    user_id { 0 }
    signatory_ip { FFaker::Internet.ip_v4_address }
    signature_phone_number { "+3306#{FFaker::PhoneNumberFR.mobile_phone_number[4..-1].gsub(' ', '')}" }
    signature_date { 25.days.ago }
    internship_agreement { create(:internship_agreement) }
    signature_image { Rack::Test::UploadedFile.new('test/fixtures/files/signature.png', 'image/png') }

    trait :school_manager do
      after(:build) do |signature|
        signature.user_id = signature.internship_agreement.school_manager.id
      end
      signatory_role { Signature.signatory_roles[:school_manager] }
    end

    trait :employer do
      after(:build) do |signature|
        signature.user_id = signature.internship_agreement.employer.id
      end
      signatory_role { Signature.signatory_roles[:employer] }
    end

    trait :student do
      after(:build) do |signature|
        signature.user_id = signature.internship_agreement.student.id
      end
      signatory_role { Signature.signatory_roles[:student] }
    end

    trait :admin_officer do
      signatory_role { Signature.signatory_roles[:admin_officer] }
    end

    trait :cpe do
      signatory_role { Signature.signatory_roles[:cpe] }
    end

    trait :student_legal_representative do
      signatory_role { Signature.signatory_roles[:student_legal_representative] }
      after(:build) do |signature|
        signature.student_legal_representative_full_name = signature.internship_agreement.student_legal_representative_full_name
      end
    end
  end
end
