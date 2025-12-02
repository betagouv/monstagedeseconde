# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class EditTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    # test 'should filter mono internship agreements' do
    #   mono_agreement = create(:mono_internship_agreement)
    #   employer = mono_agreement.internship_application.employer

    #   internship_application = create(:weekly_internship_application,
    #                                   internship_offer: create(:weekly_internship_offer, employer: employer))
    #   # multi_agreement = create(:multi_internship_agreement,
    #   #                          internship_application: internship_application)
    #   puts InternshipAgreement.last
    #   sign_in(employer)
    #   assert_equal 2, employer.internship_agreements.count    

    # end
  end
end