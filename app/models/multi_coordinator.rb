# frozen_string_literal: true

class MultiCoordinator < ApplicationRecord
  SIRET_LENGTH = 14
  EMPLOYER_NAME_MAX_LENGTH = 120
  EMPLOYER_ADDRESS_MAX_LENGTH = 250
  CITY_MAX_LENGTH = 60
  ZIPCODE_MAX_LENGTH = 6
  STREET_MAX_LENGTH = 300
  PHONE_MAX_LENGTH = 20

  belongs_to :multi_activity
  belongs_to :sector, optional: true
  belongs_to :group, -> { where(is_public: true) }, optional: true
  has_one :multi_corporation, dependent: :destroy
  has_one :multi_planning, dependent: :destroy

  attr_accessor :presentation_siret

  validates :is_public, inclusion: [true, false]
  # Le ministère (group_id) est lié à is_public, pas au secteur
  with_options if: :is_public do
    validates :group_id, presence: { message: 'Un ministère est requis pour une offre publique' }
  end
  with_options unless: :is_public do
    validates :group_id, absence: { message: "Il n'y a pas de ministère à associer à une structure privée" }
  end
  validate :sector_consistency_with_is_public

  validates :employer_chosen_name, presence: true, length: { maximum: EMPLOYER_NAME_MAX_LENGTH }
  validates :employer_chosen_address, presence: true, length: { maximum: EMPLOYER_ADDRESS_MAX_LENGTH }
  validates :city, presence: true, length: { maximum: CITY_MAX_LENGTH }
  validates :zipcode, presence: true, length: { maximum: ZIPCODE_MAX_LENGTH }
  validates :street, presence: true, length: { maximum: STREET_MAX_LENGTH }
  validates :phone, presence: true, length: { maximum: PHONE_MAX_LENGTH }
  validates :siret, length: { is: SIRET_LENGTH }, allow_blank: true
  validates :employer_name, length: { maximum: EMPLOYER_NAME_MAX_LENGTH }, allow_blank: true
  validates :employer_address, length: { maximum: EMPLOYER_ADDRESS_MAX_LENGTH }, allow_blank: true

  validate :phone_format

  delegate :employer, to: :multi_activity

  def is_fully_editable?
    true
  end

  def presenter
    @presenter ||= Presenters::MultiCoordinator.new(self)
  end

  private

  # Seule contrainte entre is_public et le secteur : une structure privée
  # ne peut pas porter le secteur "Fonction publique".
  def sector_consistency_with_is_public
    fonction_publique_sector = Sector.find_by(name: 'Fonction publique')
    return if fonction_publique_sector.nil?

    if !is_public && sector_id == fonction_publique_sector.id
      errors.add(:sector_id, "Le secteur 'Fonction publique' n'est pas autorisé pour une offre privée")
    end
  end

  def phone_format
    return if phone.blank?

    phone_pattern = ApplicationController.helpers.field_phone_pattern
    unless phone.match?(Regexp.new(phone_pattern))
      errors.add(:phone, 'Le numéro de téléphone doit être composé de 10 chiffres')
    end
  end
end
