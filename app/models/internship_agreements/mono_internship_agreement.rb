module InternshipAgreements
  class MonoInternshipAgreement < InternshipAgreement

    belongs_to :internship_application, class_name: 'InternshipApplications::WeeklyFramed'
  end
end