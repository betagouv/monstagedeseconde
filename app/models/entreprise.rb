class Entreprise < ApplicationRecord
  include StepperProxy::Entreprise

  # Associations
  belongs_to :internship_occupation
  # accepts_nested_attributes_for :tutor,
  #                               reject_if: ->(attributes) { attributes['email'].blank? },
  #                               allow_destroy: true
  has_one :tutor,
          dependent: :destroy

  has_one :planning,
          dependent: :destroy,
          foreign_key: :entreprise_id,
          inverse_of: :entreprise

  # Validations
  validates :is_public,
            inclusion: { in: [true, false] }
  validates :siret, length: { is: 14 }
  validates :entreprise_full_address,
            length: { minimum: 8, maximum: 200 },
            presence: true
  validates :employer_chosen_name,
            length: { maximum: 80 },
            allow_blank: true
  validates :employer_name,
            presence: true
  validates :entreprise_coordinates,
            exclusion: { in: [geo_point_factory(latitude: 0, longitude: 0)] }

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

  private
end
