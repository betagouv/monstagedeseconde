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

  attr_accessor :presentation_siret

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

  def is_fully_editable?
    true
  end

  def presenter
    @presenter ||= Presenters::MultiCoordinator.new(self)
  end

  private

  def phone_format
    return if phone.blank?

    phone_pattern = ApplicationController.helpers.field_phone_pattern
    unless phone.match?(Regexp.new(phone_pattern))
      errors.add(:phone, 'Le numéro de téléphone doit être composé de 10 chiffres')
    end
  end
end
