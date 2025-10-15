# frozen_string_literal: true

class InternshipOffersController < ApplicationController
  layout "search", only: :index

  with_options only: [:show] do
    before_action :set_internship_offer,
                  :check_internship_offer_is_not_discarded_or_redirect,
                  :check_internship_offer_is_published_or_redirect

    after_action :increment_internship_offer_view_count
  end

  def index
    @school_weeks_list, @preselected_weeks_list = current_user_or_visitor.compute_weeks_lists
    @preselected_weeks_list = @preselected_weeks_list.where(id: params[:week_ids]) if params[:week_ids].present?
    @school_weeks_list ||= Week.none
    @preselected_weeks_list ||= Week.none
    @school_weeks_list_array = Presenters::WeekList.new(weeks: @school_weeks_list.to_a).detailed_attributes
    @preselected_weeks_list_array = Presenters::WeekList.new(weeks: @preselected_weeks_list.to_a).detailed_attributes
    @seconde_week_ids = Week.seconde_weeks.map(&:id)
    @troisieme_week_ids = Week.troisieme_selectable_weeks.map(&:id)
    @student_grade_id = current_user&.student? ? current_user.grade_id : nil

    respond_to do |format|
      format.html do
        @params = search_query_params.merge(week_ids: params[:week_ids])
      end
      format.json do
        @internship_offers_seats = 0
        @internship_offers = finder.all
                                   .includes(:sector, :employer)

        # QPV order destroys the former internship offers distance order from school
        if current_user&.student?
          if current_user&.school&.try(:qpv)
            @internship_offers = @internship_offers.reorder("qpv DESC NULLS LAST")
          elsif current_user&.school&.try(:rep_kind).present?
            # get rep offers (sans pagination)
            rep_offers = finder.all_without_page.includes(:sector, :employer).where(rep: true)
            # get non rep offers (sans pagination)
            non_rep_offers = finder.all_without_page.includes(:sector, :employer).where(rep: false)

            combined_offers = rep_offers.to_a + non_rep_offers.to_a
            # Paginate the combined array
            @internship_offers = Kaminari.paginate_array(combined_offers).page(params[:page]).per(InternshipOffer::PAGE_SIZE)
          end
        end

        @params = search_query_params

        @internship_offers_seats_count = @internship_offers.empty? ? 0 : seats_finder.all_without_page.pluck(:max_candidates).sum
        data = {
          internshipOffers: format_internship_offers(@internship_offers),
          pageLinks: page_links,
          seats: @internship_offers_seats_count,
        }
        current_user.log_search_history @params.merge({ results_count: data[:seats] }) if current_user&.student?
        render json: data, status: 200
      end
    end
  end

  def show
    @previous_internship_offer = finder.next_from(from: @internship_offer)
    @next_internship_offer = finder.previous_from(from: @internship_offer)

    if current_user
      @internship_application = @internship_offer.internship_applications
                                                 .where(user_id: current_user_id)
                                                 .first
      @internship_offer.log_view(current_user)
    end
    @internship_application ||= @internship_offer.internship_applications
                                                 .build(user_id: current_user_id)
  end

  def apply_count
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_offer.log_apply(current_user)
  end

  def flag
    @internship_offer = InternshipOffer.find(params[:id])
    offer_and_userid_parameters = {
      internship_offer_id: @internship_offer.id,
      user_id: current_user_or_visitor&.id
    }
    parameters =  flag_params.merge(offer_and_userid_parameters)
    existing_report = InappropriateOffer.find_by(offer_and_userid_parameters)
    if current_user.present? && existing_report
      alert = "Vous avez déjà signalé cette offre comme inappropriée."
      return redirect_to internship_offer_path(@internship_offer), alert: alert
    else
      new_report = InappropriateOffer.new(parameters)
      if new_report.valid?
        new_report.save
        GodMailer.offer_was_flagged(new_report).deliver_later
        notice = "Merci, votre signalement a bien été pris en compte. Notre équipe l’examinera sous 48h."
        redirect_to internship_offer_path(@internship_offer, sans_signalement: true), notice: notice
      else
        @inappropriate_offer = new_report
        return render :show
      end
    end
  end

  private

  def set_internship_offer
    @internship_offer = InternshipOffer.find(params[:id])
  end

  def search_query_params
    common_query_params = %i[city grade_id latitude longitude page radius]
    common_query_params += [:school_year] if current_user_or_visitor.god? || current_user_or_visitor.statistician?
    params.permit(*common_query_params, week_ids: [])
  end

  def check_internship_offer_is_not_discarded_or_redirect
    return unless @internship_offer.discarded?

    redirect_to(
      user_presenter.default_internship_offers_path,
      flash: {
        warning: "Cette offre a été supprimée et n'est donc plus accessible",
      },
    )
  end

  def check_internship_offer_is_published_or_redirect
    from_email = [params[:origin], params[:origine]].include?("email")
    authenticate_user! if current_user.nil? && from_email
    return if can?(:create, @internship_offer)
    return if @internship_offer.published?

    redirect_to(
      user_presenter.default_internship_offers_path,
      flash: { warning: "Cette offre n'est plus disponible" },
    )
  end

  def current_user_id
    current_user.try(:id)
  end

  def finder
    @finder ||= Finders::InternshipOfferConsumer.new(
      params: search_query_params,
      user: current_user_or_visitor,
    )
  end

  def seats_finder
    @seats_finder ||= Finders::InternshipOfferConsumer.new(
      params: search_query_params,
      user: current_user_or_visitor,
      seats_search: true,
    )
  end

  def increment_internship_offer_view_count
    @internship_offer.stats.increment!(:view_count) if current_user&.student?
  end

  def format_internship_offers(internship_offers)
    internship_offers.map do |internship_offer|
      {
        id: internship_offer.id,
        title: internship_offer.title.truncate(44),
        description: internship_offer.description.to_s,
        employer_name: internship_offer.employer_name,
        link: internship_offer_path(internship_offer, search_query_params),
        city: internship_offer.city.capitalize,
        date_start: I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy),
        date_end: I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy),
        lat: internship_offer.coordinates.latitude,
        lon: internship_offer.coordinates.longitude,
        image: view_context.asset_pack_path("media/images/sectors/#{internship_offer.sector.cover}"),
        sector: internship_offer.sector.name,
        is_favorite: !!current_user && internship_offer.is_favorite?(current_user),
        logged_in: !!current_user,
        can_manage_favorite: can?(:create, Favorite),
        can_read_employer_name: can?(:read_employer_name, internship_offer),
        fits_for_seconde: internship_offer.fits_for_seconde?,
        fits_for_troisieme_or_quatrieme: internship_offer.fits_for_troisieme_or_quatrieme?,
        available_weeks_count: internship_offer.presenter.available_weeks_count,
        qpv: internship_offer.qpv,
        rep: internship_offer.rep,
        is_authenticated: !!current_user,
        is_student: current_user&.student?,
      }
    end
  end

  def page_links
    offers = @internship_offers
    {
      totalPages: offers.present? ? offers.total_pages : 0,
      currentPage: offers.present? ? offers.current_page : nil,
      nextPage: offers.present? ? offers.next_page : nil,
      prevPage: offers.present? ? offers.prev_page : nil,
      isFirstPage: offers.present? ? offers.first_page? : false,
      isLastPage: offers.present? ? offers.last_page? : false,
      pageUrlBase: url_for(search_query_params.except("page")),
    }
  end

  def flag_params
    params.require(:inappropriate_offer)
          .permit(:id, :ground, :details)
  end
end
