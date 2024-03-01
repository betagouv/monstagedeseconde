# frozen_string_literal: true

module InternshipApplicationCountersHooks
  class WeeklyFramed < InternshipApplicationCountersHook
    delegate :internship_offer, to: :internship_application

    # BEWARE: order matters
    def update_all_counters
      update_internship_offer_stats
      update_favorites
      true
    end

    def update_favorites
      internship_offer.update_all_favorites
    end

    def update_internship_offer_stats
      @internship_application.internship_offer.recalculate
    end

    # PERF: can be optimized with one query
    # w8 for perf issue [if it ever occures]
    # select sum(aasm_state == convention_signed) as convention_signed_count
    #        sum(aasm_state == approved) as approved_count )

    # :approved is the top aasm_state that an application can reach.
    # Agreements states are decoupled
    #---------------------------------------
    # blocked_applications_count is a column of InternshipOfferWeek
    # it counts the applications approved for each internship offer week.
    #---------------------------------------

    # Note: if a week is associated to an application that reaches the aasm_state of :approved,
    # and if that week in not listed in internship_offer_weeks,
    # then next counter could appear as bugged (see commit ad80245), but it is not

    private

    attr_reader :internship_application

    def initialize(internship_application:)
      @internship_application = internship_application
      @internship_application.reload
    end
  end
end
