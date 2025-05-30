module Dashboard
  class InternshipOfferAreasController < ApplicationController
    before_action :authenticate_user!, only: %i[index create edit update destroy new filter_by_area]
    before_action :set_internship_offer_area, only: %i[edit update destroy flip]

    def index
      authorize! :index, InternshipOfferArea
      @internship_offer_areas = current_user.internship_offer_areas
      @team_members = (current_user.pending_invitations_to_my_team.to_a +
                      current_user.refused_invitations.to_a +
                      Array(current_user.team&.team_members.to_a)).uniq
    end

    def new
      authorize! :create, InternshipOfferArea
      @internship_offer_area = current_user.internship_offer_areas.build
    end

    def edit
      authorize! :update, @internship_offer_area
      @internship_offer_areas = current_user.internship_offer_areas
    end

    def create
      authorize! :create, InternshipOfferArea
      build_params = internship_offer_area_params.merge(
        employer_type: 'User',
        employer_id: current_user.id
      )
      @internship_offer_area = current_user.internship_offer_areas.build(build_params)
      if @internship_offer_area.save
        memorize_id
        if current_user.team.alive?
          set_areas_notifications
          redirect_to edit_dashboard_internship_offer_area_path(@internship_offer_area),
                      flash: { success: 'Espace créé avec succès.' }
        else
          redirect_to dashboard_internship_offer_areas_path, notice: 'Espace créé avec succès.'
        end
      else
        respond_to do |format|
          format.turbo_stream do
            path = 'dashboard/internship_offer_areas/areas_modal_dialog'
            render turbo_stream:
              turbo_stream.replace('fr-modal-add-space-dialog',
                                   partial: path,
                                   locals: { current_user:,
                                             internship_offer_area: @internship_offer_area })
          end
        end
      end
    end

    def filter_by_area
      authorize! :index, InternshipOfferArea
      current_user.current_area_id_memorize(params[:id])
      if current_user.internship_applications.any?
        redirect_to dashboard_candidatures_path
      else
        redirect_to dashboard_internship_offers_path
      end
    end

    def update
      authorize! :update, @internship_offer_area
      if @internship_offer_area.update(internship_offer_area_params)
        notice = 'Modification du nom d\'espace opérée'
        if params[:internship_offer_area][:from_dashboard]
          redirect_to dashboard_internship_offer_areas_path, notice:
        else
          redirect_to dashboard_internship_offers_path,
                      notice:
        end
      else
        respond_to do |format|
          format.turbo_stream do
            path = 'dashboard/internship_offer_areas/edit_areas_modal_dialog'
            render turbo_stream:
              turbo_stream.replace('fr-modal-edit-space-dialog',
                                   partial: path,
                                   locals: { current_user:,
                                             internship_offer_area: @internship_offer_area })
          end
        end
      end
    end

    def flip
      authorize! :update, @internship_offer_area
      raise 'boom' if @internship_offer_area.nil?

      @area_notification = fetch_area_notification ||
                           quick_nofif_creation(area: internship_offer_area)
      respond_to do |format|
        format.turbo_stream do
          path = 'dashboard/internship_offer_areas/area_notifications/toggle'
          render turbo_stream:
            turbo_stream.replace("toggle_notif_#{dom_id(@area_notification)}",
                                 partial: path,
                                 locals: { area_notification: @area_notification,
                                           internship_offer_area: @internship_offer_area })
        end
      end
    rescue ActiveRecord::RecordInvalid
      render :edit, status: :unprocessable_entity
    end

    # interface shows a destroy button when there is more than one area
    # transfer possibilities exists only for teams => these are the specific areas
    # provided by the form
    def destroy
      authorize! :destroy, @internship_offer_area
      target_area = @internship_offer_area.team_sibling_area_sample

      redirect_to dashboard_internship_offer_areas_path and return if params[:commit] != 'Valider'

      if pure_destruction?(params)

        if current_user.current_area_id == @internship_offer_area.id
          redirect_to dashboard_internship_offer_areas_path,
                      flash: { danger: 'Impossible de supprimer l\'espace actuel.' }
          return
        end

        ActiveRecord::Base.transaction do
          @internship_offer_area.internship_offers.each do |offer|
            offer.internship_applications.destroy_all
            offer.anonymize
          end
          # update all users with the area in current_area_id, to the user current_area_id
          User.where(current_area_id: @internship_offer_area.id).update_all(current_area_id: current_user.current_area_id)
          # update all internship_offer with the area in internship_offer_area_id, to the user current_area_id
          InternshipOffer.where(internship_offer_area_id: @internship_offer_area.id).update_all(internship_offer_area_id: current_user.current_area_id)
          @internship_offer_area.destroy!
        end

      elsif current_user.internship_offer_areas.count == 1

        @internship_offer_area.destroy!
      else
        move_internship_offers_to_specific_area(params)
        clean_user_references_to_area(
          target_area_id: target_area.id || form_target_area_id,
          to_be_removed_area_id: @internship_offer_area
        )
        @internship_offer_area.destroy!
      end
      redirect_to dashboard_internship_offer_areas_path,
                  flash: { success: 'Espace supprimé avec succès.' }
    rescue ActiveRecord::RecordInvalid
      render :new, status: :bad_request
    end

    private

    def form_target_area_id
      params["radio-hint_internship_offer_area_#{params[:id]}"]
    end

    def pure_destruction?(params)
      form_target_area_id.to_i.zero?
    end

    def fetch_area_notification
      AreaNotification.find_by(user_id: current_user.id,
                               internship_offer_area_id: @internship_offer_area.id)
    end

    def quick_nofif_creation(area:)
      AreaNotification.create!(
        user_id: current_user.id,
        internship_offer_area_id: area.id,
        notify: true
      )
    end

    def memorize_id
      current_user.current_area_id_memorize(@internship_offer_area.id)
    end

    def move_internship_offers_to_specific_area(params)
      target_area = InternshipOfferArea.find(form_target_area_id)
      @internship_offer_area.internship_offers.each do |offer|
        offer.update!(internship_offer_area: target_area)
      end
    end

    def clean_user_references_to_area(target_area_id:, to_be_removed_area_id:)
      user_to_update_list = [current_user]
      if current_user.team.alive?
        current_user.db_team_members.each do |user|
          next unless user.current_area_id == to_be_removed_area_id

          user_to_update_list << user if user.id != current_user.id
        end
      end
      user_to_update_list.each { |user| user.current_area_id_memorize(target_area_id) }
    end

    def set_areas_notifications
      current_user.team_members_ids.each do |user_id|
        AreaNotification.create!(
          user_id:,
          internship_offer_area_id: @internship_offer_area.id,
          notify: true
        )
      end
    end

    def internship_offer_area_params
      params.require(:internship_offer_area).permit(:area_id, :name)
    end

    def set_internship_offer_area
      @internship_offer_area = InternshipOfferArea.find(params[:id])
    end
  end
end
