class SplitOfferJob < ActiveJob::Base
  queue_as :default

  def perform(internship_offer_id:)
    internship_offer = InternshipOffer.find_by(id: internship_offer_id)
    return if internship_offer.nil?

    internship_offer.split_in_two if internship_offer.has_weeks_in_the_past_and_in_the_future?
  end
end
