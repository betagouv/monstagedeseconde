# frozen_string_literal: true

module Reporting
  class BoardingHousesController < BaseReportingController
    before_action :authenticate_user!
    before_action :set_boarding_house, only: %i[edit update destroy]
    before_action :ensure_god_user!, only: %i[new create import]

    def index
      authorize! :manage_boarding_houses, current_user
      @boarding_houses = boarding_houses_scope.order(:name)
                                             .page(params[:page])
    end

    def new
      authorize! :manage_boarding_houses, current_user
      @boarding_house = BoardingHouse.new(academy: current_user_academy)
    end

    def create
      authorize! :manage_boarding_houses, current_user
      @boarding_house = BoardingHouse.new(boarding_house_params)
      assign_academy_from_zipcode if god_user?
      @boarding_house.academy ||= current_user_academy
      geocode_boarding_house
      if @boarding_house.save
        redirect_to reporting_boarding_houses_path, notice: 'Internat créé avec succès.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :manage_boarding_houses, current_user
    end

    def update
      authorize! :manage_boarding_houses, current_user
      @boarding_house.assign_attributes(boarding_house_params)
      assign_academy_from_zipcode if god_user?
      geocode_boarding_house
      if @boarding_house.save
        redirect_to reporting_boarding_houses_path, notice: 'Internat mis à jour.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :manage_boarding_houses, current_user
      @boarding_house.destroy
      redirect_to reporting_boarding_houses_path, notice: 'Internat supprimé.'
    end

    def import
      authorize! :manage_boarding_houses, current_user
      file = params[:file]
      if file.blank?
        redirect_to reporting_boarding_houses_path, alert: 'Veuillez sélectionner un fichier.'
        return
      end
      academy = god_user? ? nil : current_user.academy
      result = Services::BoardingHouseImporter.new(file: file, academy: academy).call
      expected_headers = Services::BoardingHouseImporter::COLUMN_MAPPING.keys
      matched_headers = result[:headers] & expected_headers

      if matched_headers.empty?
        redirect_to reporting_boarding_houses_path,
                    alert: "Aucune colonne reconnue dans le fichier. " \
                           "Les en-têtes attendus sont : #{expected_headers.join(', ')}. " \
                           "En-têtes trouvés : #{result[:headers].join(', ')}."
      elsif result[:created] == 0 && result[:errors].empty?
        redirect_to reporting_boarding_houses_path,
                    alert: "Aucun internat importé. #{result[:skipped]} ligne(s) ignorée(s) (nom manquant). " \
                           "Vérifiez que votre fichier contient une colonne « Nom » renseignée."
      elsif result[:errors].any?
        error_details = result[:errors].map { |e| "Ligne #{e[:row]} : #{e[:errors].join(', ')}" }.join(' | ')
        redirect_to reporting_boarding_houses_path,
                    alert: "#{result[:created]} créé(s), #{result[:errors].count} erreur(s) sur #{result[:total]} ligne(s). #{error_details}"
      else
        redirect_to reporting_boarding_houses_path,
                    notice: "#{result[:created]} internat(s) importé(s) avec succès."
      end
    rescue StandardError => e
      redirect_to reporting_boarding_houses_path,
                  alert: "Erreur lors de l'import : #{e.message}"
    end

    private

    def god_user?
      current_user.is_a?(Users::God)
    end

    def ensure_god_user!
      redirect_to reporting_boarding_houses_path, alert: 'Action non autorisée.' unless god_user?
    end

    def current_user_academy
      god_user? ? nil : current_user.academy
    end

    def boarding_houses_scope
      if god_user?
        BoardingHouse.all
      else
        current_user.academy.boarding_houses
      end
    end

    def set_boarding_house
      @boarding_house = boarding_houses_scope.find(params[:id])
    end

    def boarding_house_params
      params.require(:boarding_house).permit(
        :name, :street, :zipcode, :city,
        :contact_phone, :contact_email,
        :available_places, :reference_date
      )
    end

    def assign_academy_from_zipcode
      return if @boarding_house.zipcode.blank?

      dept = Department.fetch_by_zipcode(zipcode: @boarding_house.zipcode)
      @boarding_house.academy = dept.academy if dept
    end

    def geocode_boarding_house
      return if @boarding_house.coordinates.present? &&
                @boarding_house.coordinates.latitude != 0 &&
                @boarding_house.coordinates.longitude != 0

      address = [@boarding_house.street, @boarding_house.zipcode, @boarding_house.city].compact.join(' ')
      coords = Geocoder.coordinates(address)
      @boarding_house.coordinates = { latitude: coords[0], longitude: coords[1] } if coords
    rescue StandardError => e
      Rails.logger.warn("Geocoding failed for boarding house: #{e.message}")
    end
  end
end
