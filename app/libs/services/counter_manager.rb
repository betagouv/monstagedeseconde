# frozen_string_literal: true

# Services::CounterManager.reset_internship_offer_counters
# Services::CounterManager.reset_internship_offer_weeks_counter
module Services
  class CounterManager
    def self.reset_internship_offer_counters
      InternshipOffer.kept.update_all(
        total_applications_count: 0,
        total_male_applications_count: 0,
        total_female_applications_count: 0,
        submitted_applications_count: 0,
        approved_applications_count: 0,
        total_male_approved_applications_count: 0,
        total_female_approved_applications_count: 0,
        rejected_applications_count: 0
      )
      InternshipApplication.all.map(&:update_all_counters)
    end

    def self.reset_one_internship_offer_counter(internship_offer: )
      ok = true
      return ok if internship_offer.is_a?(InternshipOffers::Api)

      ActiveRecord::Base.transaction do
        res = internship_offer.update(
          total_applications_count: 0,
          total_male_applications_count: 0,
          total_female_applications_count: 0,
          submitted_applications_count: 0,
          approved_applications_count: 0,
          total_male_approved_applications_count: 0,
          total_female_approved_applications_count: 0,
          rejected_applications_count: 0
        )

        internship_offer.internship_applications
                        .each do |internship_application|
          res &&= internship_application.update_all_counters
        end

        unless !!res
          Rails.logger.info '================'
          Rails.logger.info "reset_one_internship_offer_counter : internship_offer.id : #{internship_offer.id}"
          Rails.logger.info '================'
          Rails.logger.info ''
          ok = false
          raise ActiveRecord::Rollback
        end
      end
      ok
    end
  end
end
