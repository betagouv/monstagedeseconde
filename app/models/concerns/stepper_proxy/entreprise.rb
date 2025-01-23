module StepperProxy
  module Entreprise
    extend ActiveSupport::Concern

    included do
      # belongs_to :group, optional: true
      # TODO
      # normalizes :contact_phone, with: ->(contact_phone) { User.sanitize_mobile_phone_number(contact_phone) }
      belongs_to :group, -> { where is_public: true }, optional: true
      belongs_to :sector

      before_validation :clean_siret, unless: -> { internship_address_manual_enter }
      before_save :entreprise_used_name

      attr_accessor :entreprise_chosen_full_address,
                    :entreprise_coordinates_longitude,
                    :entreprise_coordinates_latitude

      validates :employer_chosen_name,
                length: { maximum: 150 },
                allow_blank: true
      validates :employer_name,
                presence: true,
                length: { maximum: 150 }
      validates :entreprise_coordinates,
                exclusion: { in: [geo_point_factory(latitude: 0, longitude: 0)] },
                unless: -> { internship_address_manual_enter }
      validates :is_public, inclusion: [true, false]

      def entreprise_coordinates=(coordinates)
        case coordinates
        when Hash
          if coordinates[:latitude]
            super(geo_point_factory(latitude: coordinates[:latitude], longitude: coordinates[:longitude]))
          else
            super(geo_point_factory(latitude: coordinates['latitude'],
                                    longitude: coordinates['longitude']))
          end
        when RGeo::Geographic::SphericalPointImpl
          super(coordinates)
        else
          super
        end
      end

      private

      def clean_siret
        self.siret = siret.gsub(' ', '') if try(:siret)
      end

      def entreprise_used_name
        self.employer_name = employer_chosen_name.presence || employer_name
      end
    end
  end
end
