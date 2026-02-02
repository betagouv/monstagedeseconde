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
      before_validation :public_entreprise_sector_settings, if: -> { is_public }
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

      # Offre publique : group_id requis et secteur "Fonction publique"
      with_options if: :is_public do
        validates :group_id, presence: { message: "Un ministère est requis pour une offre publique" }
      end

      # Offre privée : group_id interdit et secteur différent de "Fonction publique"
      with_options unless: :is_public do
        validates :group_id, absence: { message: "Il n'y a pas de ministère à associer à une entreprise privée" }
      end

      validate :sector_consistency_with_is_public
      after_validation :report_group_id_consistency_errors

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

      def public_entreprise_sector_settings
        self.sector = Sector.find_by(name: 'Fonction publique')
      end

      def sector_consistency_with_is_public
        fonction_publique_sector = Sector.find_by(name: 'Fonction publique')
        return if fonction_publique_sector.nil?

        if is_public && sector_id != fonction_publique_sector.id
          report_public_private_consistency_error("Offre publique avec secteur différent de 'Fonction publique'")
          errors.add(:sector_id, "Le secteur doit être 'Fonction publique' pour une offre publique")
        elsif !is_public && sector_id == fonction_publique_sector.id
          report_public_private_consistency_error("Offre privée avec secteur 'Fonction publique'")
          errors.add(:sector_id, "Le secteur 'Fonction publique' n'est pas autorisé pour une offre privée")
        end
      end

      def report_group_id_consistency_errors
        return unless errors[:group_id].any?

        message = if is_public
                    "Offre publique sans group_id (ministère manquant)"
                  else
                    "Offre privée avec group_id (ministère non autorisé)"
                  end
        report_public_private_consistency_error(message)
      end

      def report_public_private_consistency_error(message)
        Sentry.capture_message(
          "Incohérence is_public/sector/group_id: #{message}",
          level: :warning,
          extra: {
            model_class: self.class.name,
            record_id: id,
            is_public: is_public,
            sector_id: sector_id,
            sector_name: sector&.name,
            group_id: group_id,
            group_name: group&.name,
            user_id: Current.user&.id,
            user_type: Current.user&.type,
            request_url: Current.request_url,
            request_params: Current.request_params,
            request_id: Current.request_id
          },
          tags: {
            error_type: 'public_private_consistency',
            model: self.class.name
          }
        )
      end
    end
  end
end
