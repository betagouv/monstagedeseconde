# frozen_string_literal: true

require 'test_helper'

module Finders
  include TeamAndAreasHelper
  class TabEmployerTest < ActiveSupport::TestCase
    test 'pending_agreements_count only draft agreements' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_3eme, employer: employer, max_candidates: 2)
      draft_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      completed_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      completed_application.internship_agreement.update(aasm_state: :completed_by_employer)

      employer_tab = TabEmployer.new(user: employer)
      assert_equal 1, employer_tab.pending_agreements_count
    end

    test '.pending_internship_applications_actions_count' do
      employer = create(:employer)
      InternshipApplication.aasm.states.each do |state|
        student = create(:student)
        wio = create(:weekly_internship_offer_3eme,
                     employer: employer,
                     internship_offer_area: employer.current_area)
        create(
          :weekly_internship_application,
          aasm_state: state.name.to_sym,
          internship_offer: wio,
          student: student
        )
      end
      tab_value = TabEmployer.new(user: employer)
                             .pending_internship_applications_actions_count
      # 1 for :read_by_employer,
      # 1 for :submitted,
      assert_equal 2, tab_value
    end
  end
end
