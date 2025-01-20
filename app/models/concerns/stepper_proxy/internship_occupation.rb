# wrap shared behaviour between internship offer / internship_occupation [by stepper]
module StepperProxy
  module InternshipOccupation
    extend ActiveSupport::Concern

    included do
      include Nearbyable

      before_save :set_department

      validates :title,
                :description,
                :street,
                :zipcode,
                :city, presence: true

      validates :description,
                length: { maximum: InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT }
      validates :title, length: { maximum: 150 }

      def set_department
        self.department = Department.lookup_by_zipcode(zipcode: zipcode)
      end
    end
  end
end
