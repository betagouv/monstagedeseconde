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
      before_validation :public_entreprise_sector_settings, if: -> { is_public && !from_api? }
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
      with_options if: :is_public, unless: :from_api? do
        validates :group_id, presence: { message: "Un ministère est requis pour une offre publique" }
      end

      # Offre privée : group_id interdit et secteur différent de "Fonction publique"
      with_options unless: -> { is_public || from_api? } do
        validates :group_id, absence: { message: "Il n'y a pas de ministère à associer à une entreprise privée" }
      end

      validate :sector_consistency_with_is_public, unless: :from_api?
      after_validation :report_suspicious_data_inconsistency, unless: :from_api?

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


      def from_api?
        respond_to?(:permalink) && permalink.present?
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
          errors.add(:sector_id, "Le secteur doit être 'Fonction publique' pour une offre publique")
        elsif !is_public && sector_id == fonction_publique_sector.id
          errors.add(:sector_id, "Le secteur 'Fonction publique' n'est pas autorisé pour une offre privée")
        end
      end

      # Report les incohérences is_public/sector/group_id UNIQUEMENT si :
      # - Il y a des erreurs de validation sur group_id OU sector_id
      # - ET ces erreurs correspondent à une incohérence is_public/sector/group_id
      def report_suspicious_data_inconsistency
        # Ne reporter que s'il y a des erreurs spécifiques sur group_id ou sector_id
        has_group_id_error = errors[:group_id].any?
        has_sector_id_error = errors[:sector_id].any?
        return unless has_group_id_error || has_sector_id_error

        fonction_publique_sector = Sector.find_by(name: 'Fonction publique')
        should_report = false
        message = nil

        # Cas : offre publique sans group_id (erreur sur group_id)
        if has_group_id_error && is_public && group_id.blank?
          should_report = true
          message = "Offre publique sans group_id (ministère manquant)"
        # Cas : offre privée avec group_id (erreur sur group_id)
        elsif has_group_id_error && !is_public && group_id.present?
          should_report = true
          message = "Offre privée avec group_id (ministère non autorisé)"
        # Cas : offre privée avec secteur "Fonction publique" (erreur sur sector_id)
        elsif has_sector_id_error && !is_public && fonction_publique_sector && sector_id == fonction_publique_sector.id
          should_report = true
          message = "Offre privée avec secteur 'Fonction publique'"
        end

        return unless should_report

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
            validation_errors: errors.to_hash,
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
