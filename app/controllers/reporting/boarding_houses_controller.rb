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

      blob = ActiveStorage::Blob.create_and_upload!(
        io: file.tempfile,
        filename: file.original_filename,
        content_type: file.content_type
      )
      academy_id = god_user? ? nil : current_user.academy&.id
      ImportBoardingHousesJob.perform_later(blob.signed_id, academy_id)

      redirect_to reporting_boarding_houses_path,
                  notice: "Import en cours. Les internats apparaîtront dans la liste au fur et à mesure. " \
                          "Vous pouvez rafraîchir la page dans quelques instants."
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
  end
end
