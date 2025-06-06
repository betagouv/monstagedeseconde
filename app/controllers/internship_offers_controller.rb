# frozen_string_literal: true

class InternshipOffersController < ApplicationController
  layout 'search', only: :index

  with_options only: [:show] do
    before_action :set_internship_offer,
                  :check_internship_offer_is_not_discarded_or_redirect,
                  :check_internship_offer_is_published_or_redirect

    after_action :increment_internship_offer_view_count
  end

  def index
    @school_weeks_list, @preselected_weeks_list = current_user_or_visitor.compute_weeks_lists

    respond_to do |format|
      format.html do
        @params = query_params.merge(sector_ids: params[:sector_ids])
      end
      format.json do
        @internship_offers_seats = 0
        @internship_offers = finder.all
                                   .includes(:sector, :employer)

        # QPV order
        if current_user&.student? && current_user&.school&.try(:qpv)
          @internship_offers = @internship_offers.reorder('qpv DESC NULLS LAST')
        end

        sql = if params[:latitude].present? && params[:longitude].present?
                <<-SQL
            SELECT SUM(internship_offers.max_candidates)
            FROM internship_offers
            INNER JOIN internship_offer_stats#{' '}
              ON internship_offer_stats.internship_offer_id = internship_offers.id
            WHERE internship_offer_stats.remaining_seats_count > 0
              AND last_date > '2025-02-13 12:23:21.417042'
              AND last_date <= '2025-08-06'
              AND internship_offers.discarded_at IS NULL
              AND internship_offers.aasm_state = 'published'
              AND internship_offers.qpv = FALSE
              AND internship_offers.rep = FALSE
              AND internship_offers.hidden_duplicate = FALSE
              AND (
                6371 * acos(
                  cos(radians($1)) *#{' '}
                  cos(radians(ST_Y(coordinates::geometry))) *#{' '}
                  cos(radians(ST_X(coordinates::geometry)) - radians($2)) +#{' '}
                  sin(radians($1)) *#{' '}
                  sin(radians(ST_Y(coordinates::geometry)))
                ) * 1000
              ) <= $3
                SQL
              else
                <<-SQL
            SELECT SUM(internship_offers.max_candidates)
            FROM internship_offers
            INNER JOIN internship_offer_stats#{' '}
              ON internship_offer_stats.internship_offer_id = internship_offers.id
            WHERE internship_offer_stats.remaining_seats_count > 0
              AND last_date > '2025-02-13 12:23:21.417042'
              AND last_date <= '2025-08-06'
              AND internship_offers.discarded_at IS NULL
              AND internship_offers.aasm_state = 'published'
              AND internship_offers.qpv = FALSE
              AND internship_offers.rep = FALSE
              AND internship_offers.hidden_duplicate = FALSE
                SQL
              end

        @internship_offers_seats = if params[:longitude].present? && params[:latitude].present?
                                     ActiveRecord::Base.connection.exec_query(
                                       sql,
                                       'SQL',
                                       [params[:latitude].to_f, params[:longitude].to_f, params[:radius].to_i]
                                     ).first['sum'] || 0
                                   else
                                     #  ActiveRecord::Base.connection.exec_query(sql).first['sum'] || 0
                                     1
                                   end

        @params = query_params
        data = {
          internshipOffers: format_internship_offers(@internship_offers),
          pageLinks: page_links,
          seats: @internship_offers_seats
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

  private

  def set_internship_offer
    @internship_offer = InternshipOffer.find(params[:id])
  end

  def query_params
    common_query_params = %i[page
                             latitude
                             longitude
                             city
                             radius
                             keyword
                             grade_id
                             period]
    if current_user_or_visitor.god? ||
       current_user_or_visitor.statistician?
      common_query_params += [:school_year]
    end
    params.permit(*common_query_params, sector_ids: [], week_ids: [])
  end

  def check_internship_offer_is_not_discarded_or_redirect
    return unless @internship_offer.discarded?

    redirect_to(
      user_presenter.default_internship_offers_path,
      flash: {
        warning: "Cette offre a été supprimée et n'est donc plus accessible"
      }
    )
  end

  def check_internship_offer_is_published_or_redirect
    from_email = [params[:origin], params[:origine]].include?('email')
    authenticate_user! if current_user.nil? && from_email
    return if can?(:create, @internship_offer)
    return if @internship_offer.published?

    redirect_to(
      user_presenter.default_internship_offers_path,
      flash: { warning: "Cette offre n'est plus disponible" }
    )
  end

  def current_user_id
    current_user.try(:id)
  end

  def finder
    @finder ||= Finders::InternshipOfferConsumer.new(
      params: params.permit(
        :page,
        :latitude,
        :longitude,
        :radius
        # :keyword,
        # :school_year,
        # :grade_id,
        # week_ids: [],
        # sector_ids: []
      ),
      user: current_user_or_visitor
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
