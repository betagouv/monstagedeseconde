FactoryBot.define do
  factory :event_report do
    event_name { "educonnect.failure" }
    stage { "callbacks_controller.educonnect.sign_in" }
    severity { 3 }
    student_ine { "1234567890" }
    json_payload do
      {
        "message" => "test failure",
        "school_uai" => "0590121L"
      }
    end
    code_line { "120" }
    tag { "educonnect_failure" }
  end
end
