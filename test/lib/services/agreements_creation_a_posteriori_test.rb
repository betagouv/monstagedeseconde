require 'test_helper'

module Services
  class AgreementsCreationAPosterioriTest < ActiveSupport::TestCase
    test 'perform with no school_manager in this school' do
      ministry_statistician = create(:ministry_statistician)
      internship_offer = create(:weekly_internship_offer_2nde, employer: ministry_statistician)
      school = create(:school)
      student = create(:student, school:, class_room: create(:class_room, school:))
      internship_application = create(:weekly_internship_application,
                                      internship_offer:,
                                      student:)
      internship_application.employer_validate!
      internship_application.approve!

      Services::AgreementsAPosteriori.new(employer_id: ministry_statistician.id).perform

      assert_equal 0, InternshipAgreement.count
    end

    test 'perform with school_manager in this school produces an internship_agreement' do
      travel_to Date.new(2024, 1, 1) do
        ministry_statistician = create(:ministry_statistician, agreement_signatorable: false)
        internship_offer = create(:weekly_internship_offer_2nde, employer: ministry_statistician)
        school = create(:school, :with_school_manager)
        student = create(:student, school:, class_room: create(:class_room, school:))
        internship_application = create(:weekly_internship_application,
                                        internship_offer:,
                                        student:)
        internship_application.employer_validate!
        internship_application.approve!

        Services::AgreementsAPosteriori.new(employer_id: ministry_statistician.id).perform

        assert_equal 0, InternshipAgreement.count

        ministry_statistician.update_column(:agreement_signatorable, true)

        Services::AgreementsAPosteriori.new(employer_id: ministry_statistician.id).perform

        assert_equal 1, InternshipAgreement.count
      end
    end
  end
end
