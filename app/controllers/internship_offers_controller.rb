# frozen_string_literal: true

class InternshipOffersController < ApplicationController
  layout 'search', only: :index

  with_options only: [:show] do
    before_action :set_internship_offer
    before_action :check_internship_offer_status
    after_action :increment_internship_offer_view_count
  end

  def index
    @school_weeks_list, @preselected_weeks_list = current_user_or_visitor.compute_weeks_lists

    respond_to do |format|
      format.html { @params = query_params.merge(sector_ids: params[:sector_ids]) }
      format.json { render json: fetch_internship_offers, status: 200 }
    end
  end

  def show
    @previous_internship_offer = finder.next_from(from: @internship_offer)
    @next_internship_offer = finder.previous_from(from: @internship_offer)

    if current_user
      @internship_application = @internship_offer.internship_applications
                                                 .find_by(user_id: current_user_id)
      @internship_offer.log_view(current_user)
    end
    @internship_application ||= @internship_offer.internship_applications
                                                 .build(user_id: current_user_id)
  end

  def apply_count
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_offer.log_apply(current_user)
  end

  private

  def set_internship_offer
    @internship_offer = InternshipOffer.find(params[:id])
  end

  def check_internship_offer_status
    if @internship_offer.discarded?
      redirect_to user_presenter.default_internship_offers_path,
                  flash: { warning: "Cette offre a été supprimée et n'est donc plus accessible" }
    elsif !@internship_offer.published? && !can?(:create, @internship_offer)
      redirect_to user_presenter.default_internship_offers_path,
                  flash: {
                    warning: "Cette offre a été supprimée et n'est donc plus accessible"
                  }
    end
  end

  def fetch_internship_offers
    t0 = Time.now
    @internship_offers_seats = 0
    @internship_offers = finder.all.includes(:sector, :employer)

    if current_user&.student? && current_user&.school&.try(:qpv)
      @internship_offers = @internship_offers.reorder('qpv DESC NULLS LAST')
    end

    @internship_offers_seats = calculate_seats
    if current_user&.student?
      current_user.log_search_history(query_params.merge(results_count: @internship_offers_seats))
    end

    t1 = Time.now
    Rails.logger.info("Search took #{t1 - t0} seconds")

    {
      internshipOffers: format_internship_offers(@internship_offers),
      pageLinks: page_links,
      seats: @internship_offers_seats
    }
  end

  def calculate_seats
    sql = build_seat_query
    ActiveRecord::Base.connection.exec_query(sql, 'SQL', query_bindings).first['sum'] || 0
  end

  def build_seat_query
    if params[:latitude].present? && params[:longitude].present?
      <<-SQL
        SELECT SUM(internship_offers.max_candidates)
        FROM internship_offers
        INNER JOIN internship_offer_stats ON internship_offer_stats.internship_offer_id = internship_offers.id
        WHERE internship_offer_stats.remaining_seats_count > 0
          AND last_date > '#{Date.today}'
          AND last_date <= '#{Date.today + 6.months}'
          AND internship_offers.discarded_at IS NULL
          AND internship_offers.aasm_state = 'published'
          AND internship_offers.qpv = FALSE
          AND internship_offers.rep = FALSE
          AND internship_offers.hidden_duplicate = FALSE
          AND (
            6371 * acos(
              cos(radians($1)) * cos(radians(ST_Y(coordinates::geometry))) *
              cos(radians(ST_X(coordinates::geometry)) - radians($2)) +
              sin(radians($1)) * sin(radians(ST_Y(coordinates::geometry)))
            ) * 1000
          ) <= $3
      SQL
    else
      <<-SQL
        SELECT SUM(internship_offers.max_candidates)
        FROM internship_offers
        INNER JOIN internship_offer_stats ON internship_offer_stats.internship_offer_id = internship_offers.id
        WHERE internship_offer_stats.remaining_seats_count > 0
          AND last_date > '#{Date.today}'
          AND last_date <= '#{Date.today + 6.months}'
          AND internship_offers.discarded_at IS NULL
          AND internship_offers.aasm_state = 'published'
          AND internship_offers.qpv = FALSE
          AND internship_offers.rep = FALSE
          AND internship_offers.hidden_duplicate = FALSE
      SQL
    end
  end

  def query_bindings
    if params[:latitude].present? && params[:longitude].present?
      [params[:latitude].to_f, params[:longitude].to_f, params[:radius].to_i]
    else
      []
    end
  end

  def query_params
    params.permit(:page, :latitude, :longitude, :city, :radius, :keyword, :grade_id, :period, sector_ids: [],
                                                                                              week_ids: [])
  end

  def finder
    @finder ||= Finders::InternshipOfferConsumer.new(params: query_params, user: current_user_or_visitor)
  end

  def format_internship_offers(internship_offers)
    internship_offers.map do |internship_offer|
      {
        id: internship_offer.id,
        title: internship_offer.title.truncate(44),
        description: internship_offer.description.to_s,
        employer_name: internship_offer.employer_name,
        link: internship_offer_path(internship_offer, query_params),
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
        is_authenticated: !!current_user
      }
    end
  end

  def page_links
    offers = @internship_offers
    return nil if offers.to_a.size < 1 || @is_suggestion

    {
      totalPages: offers.total_pages,
      currentPage: offers.current_page,
      nextPage: offers.next_page,
      prevPage: offers.prev_page,
      isFirstPage: offers.first_page?,
      isLastPage: offers.last_page?,
      pageUrlBase: url_for(query_params.except('page'))
    }
  end
end
