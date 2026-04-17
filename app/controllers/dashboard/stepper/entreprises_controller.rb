module Dashboard::Stepper
  class EntreprisesController < ApplicationController
    # step 2
    before_action :authenticate_user!
    before_action :fetch_entreprise, only: %i[edit update]
    before_action :sanitize_content, only: %i[create update]

    def new
      @entreprise = Entreprise.new(internship_occupation_id: params[:internship_occupation_id])
      @internship_occupation = @entreprise.internship_occupation
      authorize! :create, @entreprise
      @duplication = false
      @edit_mode = false
    end

    def create
      @entreprise = Entreprise.new(entreprise_params)
      authorize! :create, @entreprise
      set_computed_params

      if @entreprise.errors.any?
        log_error(object: @entreprise)
        render :new, status: :bad_request
        return
      end

      if @entreprise.save
        notice = "Les informations de l'entreprise ont bien été enregistrées"
        redirect_to new_dashboard_stepper_planning_path(entreprise_id: @entreprise.id), notice:
      else
        log_error(object: @entreprise)
        render :new, status: :bad_request
      end
    end

    def edit
      authorize! :edit, @entreprise
      @entreprise.entreprise_chosen_full_address = @entreprise.entreprise_full_address
      @duplication = false
      @edit_mode = true
    end

    # process update following a back to step 2
    def update
      authorize! :update, @entreprise
      set_computed_params

      if @entreprise.errors.any?
        log_error(object: @entreprise)
        render :new, status: :bad_request
        return
      end
      if @entreprise.update(entreprise_params)
        if params[:planning_id].present? && Planning.find_by(id: params[:planning_id])
          redirect_to edit_dashboard_stepper_planning_path(
            entreprise_id: @entreprise.id,
            planning_id: params[:planning_id],
            id: params[:entreprise_id]
          )
        else
          redirect_to new_dashboard_stepper_planning_path(entreprise_id: @entreprise.id)
        end
      else
        log_error(object: @entreprise)
        render :new, status: :bad_request
      end
    end

    private

    def entreprise_params
      params.require(:entreprise)
            .permit(
              :siret,
              :is_public,
              :group_id,
              :sector_id,
              :employer_name,
              :entreprise_street,
              :entreprise_zipcode,
              :entreprise_city,
              :employer_chosen_name,
              :entreprise_full_address,
              :entreprise_chosen_full_address,
              :entreprise_coordinates_longitude,
              :entreprise_coordinates_latitude,
              :contact_phone,
              :entreprise_coordinates,
              :internship_occupation_id,
              :internship_address_manual_enter,
              :workspace_conditions,
              :workspace_accessibility,
              :internship_address_manual_enter,
              :code_ape
            )
    end

    def set_computed_params
      @entreprise = set_updated_address_flag
      set_is_public_flag
      assign_coordinates
      set_full_address
      sync_sector_or_group_when_is_public_explicit
    end

    def set_is_public_flag
      @entreprise.is_public ||= entreprise_params[:is_public] == 'true'
    end

    def assign_coordinates
      coordinates = coordinates_from_params
      coordinates ||= geocoded_coordinates

      return if coordinates.blank?

      @entreprise.entreprise_coordinates = { longitude: coordinates[:longitude], latitude: coordinates[:latitude] }
    end

    def coordinates_from_params
      longitude_str = entreprise_params[:entreprise_coordinates_longitude]
      latitude_str = entreprise_params[:entreprise_coordinates_latitude]

      return if longitude_str.blank? || latitude_str.blank?

      longitude = longitude_str.to_f
      latitude = latitude_str.to_f
      return if longitude.zero? || latitude.zero?

      { longitude:, latitude: }
    end

    def geocoded_coordinates
      full_address = address_for_geocode
      return invalid_address('Adresse non trouvée, code postal invalide') unless full_address.to_s.match?(/\d{5}/)

      zipcode = full_address.to_s[/\d{5}/]
      city = geocode_city_from_zipcode(zipcode)
      return invalid_address('Adresse non trouvée') if city.blank?

      coordinates = Geofinder.coordinates("#{full_address}, #{city}, #{zipcode}, France")
      return coordinates_hash(coordinates) if coordinates.present?

      fallback_coordinates = Geocoder.search("#{city}, #{zipcode}, France")&.first&.coordinates
      if fallback_coordinates.nil?
        chosen_address = entreprise_params[:entreprise_chosen_full_address]
        fallback_coordinates = Geocoder.search("#{chosen_address}, France")&.first&.coordinates
      end

      return invalid_address('Adresse non trouvée') if fallback_coordinates.blank?

      coordinates_hash(fallback_coordinates)
    end

    def geocode_city_from_zipcode(zipcode)
      Geocoder.search("#{zipcode}, France")&.first&.city
    end

    def coordinates_hash(coordinates)
      { longitude: coordinates[1], latitude: coordinates[0] }
    end

    def address_for_geocode
      entreprise_params[:entreprise_full_address].blank? ? entreprise_params[:entreprise_chosen_full_address] : entreprise_params[:entreprise_full_address]
    end

    def invalid_address(message)
      @entreprise.errors.add(:entreprise_chosen_full_address, message)
      nil
    end

    def set_full_address
      @entreprise.entreprise_full_address = entreprise_params[:entreprise_chosen_full_address]
    end

    def sync_sector_or_group_when_is_public_explicit
      return unless entreprise_params.key?(:is_public)

      is_public_value = ActiveModel::Type::Boolean.new.cast(entreprise_params[:is_public])
      if is_public_value
        @entreprise.sector_id = Sector.find_by(name: 'Fonction publique').try(:id)
      else
        params[:entreprise][:group_id] = nil
      end
    end

    def set_updated_address_flag
      @entreprise.tap do |e|
        e.updated_entreprise_full_address = e.entreprise_full_address != entreprise_params[:entreprise_chosen_full_address]
      end
    end

    def fetch_entreprise
      id = params[:id] || params[:entreprise_id]
      @entreprise = Entreprise.find(id)
    end

    def sanitize_content
      if entreprise_params[:workspace_conditions].present?
        entreprise_params[:workspace_conditions] =
          strip_content(entreprise_params[:workspace_conditions])
      end

      return unless entreprise_params[:workspace_accessibility].present?

      entreprise_params[:workspace_accessibility] =
        strip_content(entreprise_params[:workspace_accessibility])
    end
  end
end
