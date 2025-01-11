# frozen_string_literal: true

module Dashboard
  class InternshipOffersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_internship_offer,
                  only: %i[edit update destroy republish]

    helper_method :order_direction

    def index
      @internship_offer_areas = current_user.internship_offer_areas if current_user.employer_like?
      authorize! :index, Acl::InternshipOfferDashboard.new(user: current_user)
      @internship_offers = finder.all
      order_param = order_direction.nil? ? :published_at : { order_column => order_direction }
      @internship_offers = @internship_offers.order(order_param)
      return unless params[:search].present?

      @internship_offers = @internship_offers.where(
        'title ILIKE :search OR employer_name ILIKE :search OR city ILIKE :search',
        search: "%#{params[:search]}%"
      )
    end

    # when duplicating
    def new
      @duplication = true
      @edit_mode = true
      authorize! :create, InternshipOffer
      internship_offer = current_user.internship_offers
                                     .find(params[:duplicate_id])
                                     .duplicate # A revoir TODO

      @internship_offer = if params[:without_location].present?
                            internship_offer.duplicate_without_location
                          else
                            internship_offer.duplicate
                          end

      @available_weeks = Week.both_school_track_selectable_weeks
      @internship_offer.grade_college = @internship_offer.fits_for_troisieme_or_quatrieme? ? '1' : '0'
      @internship_offer.grade_2e = @internship_offer.fits_for_seconde? ? '1' : '0'
      @internship_offer.all_year_long = @internship_offer.all_year_long?
      @internship_offer.entreprise_chosen_full_address = @internship_offer.entreprise_full_address
    end

    # duplication submit
    def create
      @duplication = true
      authorize! :create, InternshipOffer
      internship_offer_builder.create(params: internship_offer_params) do |on|
        on.success do |created_internship_offer|
          @internship_offer = created_internship_offer
          @internship_offer = Dto::PlanningAdapter.new(instance: @internship_offer, params: internship_offer_params,
                                                       current_user:)
                                                  .manage_planning_associations
                                                  .instance
          @available_weeks = Week.troisieme_weeks
          success_message = if params[:commit] == 'Renouveler l\'offre'
                              'Votre offre de stage a été renouvelée pour cette année scolaire.'
                            else
                              "L'offre de stage a été dupliquée en tenant compte" \
                              ' de vos éventuelles modifications.'
                            end
          redirect_to(internship_offer_path(created_internship_offer, stepper: true),
                      flash: { success: success_message })
        end
        on.failure do |failed_internship_offer|
          @internship_offer = failed_internship_offer || InternshipOffer.new
          render :new, status: :bad_request
        end
      end
    rescue ActionController::ParameterMissing
      @internship_offer = InternshipOffer.new
      render :new, status: :bad_request
    end

    def edit
      authorize! :update, @internship_offer
      @available_weeks = Week.both_school_track_selectable_weeks
      @internship_offer.grade_college = @internship_offer.fits_for_troisieme_or_quatrieme? ? '1' : '0'
      @internship_offer.grade_2e = @internship_offer.fits_for_seconde? ? '1' : '0'
      @internship_offer.all_year_long = @internship_offer.all_year_long? # ? strange ... removal seems possible
      @internship_offer.entreprise_chosen_full_address = @internship_offer.entreprise_full_address
      @republish = true
    end

    def update
      authorize! :update, @internship_offer
      @available_weeks = Week.troisieme_selectable_weeks # TODO : check if it's the right weeks
      internship_offer_builder.update(instance: @internship_offer,
                                      params: internship_offer_params) do |on|
        on.success do |_updated_internship_offer|
          respond_to do |format|
            format.turbo_stream
            format.html do
              redirect_to dashboard_internship_offers_path(origine: 'dashboard'),
                          flash: { success: 'Votre annonce a bien été modifiée' }
            end
          end
        end
        on.failure do |failed_internship_offer|
          respond_to do |format|
            format.html do
              @internship_offer = failed_internship_offer
              render :edit, status: :bad_request
            end
          end
        end
      rescue ActionController::ParameterMissing
        respond_to do |format|
          format.html do
            render :edit, status: :bad_request
          end
        end
      end
    end

    def destroy
      authorize! :update, @internship_offer
      internship_offer_builder.discard(instance: @internship_offer) do |on|
        on.success do
          redirect_to(dashboard_internship_offers_path,
                      flash: { success: 'Votre annonce a bien été supprimée' })
        end
        on.failure do |_failed_internship_offer|
          redirect_to(dashboard_internship_offers_path,
                      flash: { warning: "Votre annonce n'a pas été supprimée" })
        end
      end
    end

    def publish
      @internship_offer = InternshipOffer.find(params[:id])
      authorize! :publish, @internship_offer
      if @internship_offer.requires_updates?
        republish
      else
        @internship_offer.publish! unless @internship_offer.published?
        redirect_to dashboard_internship_offers_path(origine: 'dashboard'),
                    flash: { success: 'Votre annonce a bien été publiée' }
      end
    end

    def republish
      anchor = 'max_candidates_fields'
      warning = "Votre annonce n'est pas encore republiée, car il faut ajouter des places et des semaines de stage"

      if @internship_offer.remaining_seats_count.zero?
        warning = "Votre annonce n'est pas encore republiée, car il faut ajouter des places de stage"
      elsif @internship_offer.remaining_seats_count > 0
        anchor = 'weeks_container'
        warning = "Votre annonce n'est pas encore republiée, car il faut ajouter des semaines de stage"
      end
      redirect_to edit_dashboard_internship_offer_path(@internship_offer, anchor:),
                  flash: { warning: }
    end

    # duplicate form

    private

    VALID_ORDER_COLUMNS = %w[
      title
      approved_applications_count
      remaining_seats_count
    ].freeze

    def valid_order_column?
      VALID_ORDER_COLUMNS.include?(params[:order])
    end

    # def offer_contains_stepper_informations?
    #   !!(@internship_offer.practical_info_id &&
    #     @internship_offer.hosting_info_id &&
    #     @internship_offer.internship_offer_info_id &&
    #     @internship_offer.organisation_id)
    # end

    def finder
      @finder ||= Finders::InternshipOfferPublisher.new(
        params: params.permit(
          :page,
          :latitude,
          :longitude,
          :radius,
          :keyword,
          :school_year,
          :filter
        ),
        user: current_user_or_visitor
      )
    end

    def order_column
      if params[:order] && !valid_order_column?
        redirect_to(dashboard_internship_offers_path,
                    flash: { danger: "Impossible de trier par #{params[:order]}" })
      end
      return params[:order] if params[:order] && valid_order_column?

      :submitted_applications_count
    end

    def order_direction
      return nil unless params[:direction]

      params[:direction] if %w[asc desc].include?(params[:direction])
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user,
                                                        context: :web)
    end

    def internship_offer_params
      params.require(:internship_offer)
            .permit(:academy, :aasm_state, :city,
                    :department, :description, :employer_chosen_name, :employer_id,
                    :employer_name, :employer_type, :entreprise_chosen_full_address,
                    :entreprise_city,
                    :entreprise_coordinates_longitude, :entreprise_coordinates_latitude,
                    :entreprise_full_address,
                    :entreprise_street, :entreprise_zipcode, :grade_2e, :grade_college,
                    :group_id, :internship_address_manual_enter,
                    :is_public, :lunch_break, :max_candidates, :max_students_per_group,
                    :period, :published_at, :region, :renewed, :republish, :school_id,
                    :sector_id, :shall_publish, :siret, :street, :title, :type,
                    :user_update, :verb, :zipcode, entreprise_coordinates: {}, coordinates: {},
                    week_ids: [], grade_ids: [], daily_hours:{}, weekly_hours: [] )
    end

    def set_internship_offer
      @internship_offer = InternshipOffer.find(params[:id])
    end
  end
end
