class Entreprise < ApplicationRecord
  include StepperProxy::Entreprise
  belongs_to :internship_occupation

  belongs_to :internship_occupation
  has_one :planning, dependent: :destroy

  validates :is_public, inclusion: { in: [true, false] }
  validates :siret, length: { is: 14 }
  validates :entreprise_full_address,
            length: { minmum: 8, maximum: 200 },
            presence: true
  validates :employer_name,
            presence: true
  validates :entreprise_coordinates,
            exclusion: { in: [geo_point_factory(latitude: 0, longitude: 0)] }
  validates :tutor_first_name,
            :tutor_last_name,
            length: { maximum: 60 },
            allow_blank: true
  validates :tutor_phone,
            length: { maximum: 20 },
            allow_blank: true
  validates :tutor_email,
            length: { maximum: 80 },
            allow_blank: true
  validates :tutor_function,
            length: { maximum: 150 },
            allow_blank: true

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

  def presenter
    @presenter ||= Presenters::Entreprise.new(self)
  end

  private
end
