# wrap shared behaviour between internship offer / organisation [by stepper]
module StepperProxy
  module Organisation
    extend ActiveSupport::Concern

    included do
      include Nearbyable

      belongs_to :group, optional: true

      validates :employer_name,
                :street,
                :zipcode,
                :city, presence: true

      validates :employer_description, length: { maximum: InternshipOffer::EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT }

      validates :is_public, inclusion: { in: [true, false] }
      validates :siret, length: { is: 14 }, allow_blank: true

      validate :validate_group_is_public?, if: :is_public?
      validate :validate_group_is_not_public?, unless: :is_public?

      before_validation :clean_siret

      def validate_group_is_public?
        return if from_api?
        return if group.nil?

        errors.add(:group, 'Veuillez choisir un type d’employeur public') unless group.is_public?
      end

      def validate_group_is_not_public?
        return if from_api?
        return if group.nil?

        errors.add(:group, 'Veuillez choisir une institution de tutelle') if group.is_public?
      end

      def is_private? = !is_public?

      def clean_siret
        self.siret = self.siret.gsub(' ', '') if self.try(:siret)
      end
    end
  end
end
