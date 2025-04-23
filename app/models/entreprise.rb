class Entreprise < ApplicationRecord
  include StepperProxy::Entreprise

  # Associations
  belongs_to :internship_occupation

  has_one :planning,
          dependent: :destroy,
          foreign_key: :entreprise_id,
          inverse_of: :entreprise

  # Validations
  validates :siret,
            length: { is: 14 },
            unless: -> { internship_address_manual_enter }
  validates :entreprise_full_address,
            length: { minimum: 8, maximum: 200 },
            presence: true
  validates :contact_phone,
            format: { with: Regexp.new(ApplicationController.helpers.field_phone_pattern),
                      message: 'Le numéro de téléphone doit être composé de 10 chiffres' }
  # validate :group_id_presence_for_public_entreprise
  with_options if: :is_public do
    validates :group_id, presence: { message: 'Le ministère de tutelle est requis pour une entreprise publique' }
  end

  def entreprise_coordinates=(geolocation)
    case geolocation
    when Hash
      if geolocation[:latitude]
        super(geo_point_factory(latitude: geolocation[:latitude], longitude: geolocation[:longitude]))
      else
        super(geo_point_factory(latitude: geolocation['latitude'], longitude: geolocation['longitude']))
      end
    when RGeo::Geographic::SphericalPointImpl
      super(geolocation)
    else
      nil
    end
  end

  def is_fully_editable? = true

  def presenter
    @presenter ||= Presenters::Entreprise.new(self)
  end
end
