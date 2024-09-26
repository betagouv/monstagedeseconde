module StepperProxy
  module Entreprise
    belongs_to :group, optional: true
    belongs_to :internship_occupation

    # validates :is_public, inclusion: { in: [true, false] }
    # validates :siret, length: { is: 14 }, allow_blank: true

    # validate :validate_group_is_public?, if: :is_public?
    # validate :validate_group_is_not_public?, unless: :is_public?

    # before_validation :clean_siret

    # def validate_group_is_public?
    #   return if from_api?
    #   return if group.nil?

    #   errors.add(:group, 'Veuillez choisir un type d’employeur public') unless group.is_public?
    # end

    # def validate_group_is_not_public?
    #   return if from_api?
    #   return if group.nil?

    #   errors.add(:group, 'Veuillez choisir une institution de tutelle') if group.is_public?
    # end

    # def is_private? = !is_public?

    # def clean_siret
    #   self.siret = siret.gsub(' ', '') if try(:siret)
    # end
  end
end
