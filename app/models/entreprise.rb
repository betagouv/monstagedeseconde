class Entreprise < ApplicationRecord
  include StepperProxy::Entreprise

  # Associations
  belongs_to :internship_occupation

  has_one :planning,
          dependent: :destroy,
          foreign_key: :entreprise_id,
          inverse_of: :entreprise

  # Validations
  validates :siret, length: { is: 14 }
  validates :entreprise_full_address,
            length: { minimum: 8, maximum: 200 },
            presence: true

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
