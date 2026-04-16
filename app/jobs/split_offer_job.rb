class SplitOfferJob < ActiveJob::Base
  queue_as :default

  def perform(internship_offer_id:)
    print "-"

    offer = InternshipOffer.find(internship_offer_id)
    return unless offer.present? && offer.grades.size > 1 # safeguard

    offer.split_offer
  end
end
