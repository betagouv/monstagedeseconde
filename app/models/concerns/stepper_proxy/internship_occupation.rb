# wrap shared behaviour between internship offer / organisation [by stepper]
module StepperProxy
  module InternshipOccupation
    extend ActiveSupport::Concern

    included do
      include Nearbyable


      

      validates :title,
                :description,
                :street,
                :zipcode,
                :city, presence: true

      validates :description,
                length: { maximum: InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT }
    end
  end
end
