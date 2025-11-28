FactoryBot.define do
  factory :multi_internship_agreement do
    internship_application
    weekly_hours { "MyText" }
    daily_hours { "MyString" }
    siret { "12345678901234" }
    organisation_representative_role { "MyString" }
    student_address { "MyString" }
    student_phone { "MyString" }
    school_representative_phone { "MyString" }
    student_legal_representative_email { "MyString" }
    student_refering_teacher_email { "MyString" }
    student_legal_representative_full_name { "MyString" }
    student_refering_teacher_full_name { "MyString" }
    student_legal_representative_phone { "MyString" }
    student_legal_representative_2_full_name { "MyString" }
    student_legal_representative_2_email { "MyString" }
    student_legal_representative_2_phone { "MyString" }
    school_representative_email { "MyString" }
    student_full_name { "John Doe" }
    discarded_at { "2025-11-28 15:29:39" }
    lunch_break { "MyText" }
    legal_status { "MyString" }
    student_birth_date { "2025-11-28" }
    pai_project { false }
    pai_trousse_family { false }
    access_token { "1234567890malt12" }
    activity_scope { "MyString" }
    coordinator { association :user }
  end
end
