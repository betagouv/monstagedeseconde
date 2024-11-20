# frozen_string_literal: true

module Api
  module V1
    class InternshipOffersController < Api::Shared::InternshipOffersController
      include Api::AuthV1
      def search
        render_not_authorized and return unless current_api_user.operator.api_full_access

        @internship_offers = finder.all.includes(%i[sector employer]).order(id: :desc)
        if @current_api_user.operator.departments.any?
          @internship_offers = @internship_offers.by_department(@current_api_user.operator.departments.map(&:name))
        end

        formatted_internship_offers = format_internship_offers(@internship_offers)
        data = {
          pagination: page_links,
          internshipOffers: formatted_internship_offers
        }
        render json: data, status: 200
      end

      def create
        internship_offer_builder.create(params: create_internship_offer_params.merge(default_v1_params)) do |on|
          on.success(&method(:render_created))
          on.failure(&method(:render_validation_error))
          on.duplicate(&method(:render_duplicate))
          on.argument_error(&method(:render_argument_error))
        end
      end

      def update
        return if check_period_validity

        internship_offer_builder.update(instance: InternshipOffer.find_by!(remote_id: params[:id]),
                                        params: update_internship_offer_params.merge(default_v1_params)) do |on|
          on.success(&method(:render_ok))
          on.failure(&method(:render_validation_error))
          on.argument_error(&method(:render_argument_error))
        end
      end

      private

      def create_internship_offer_params
        params.require(:internship_offer)
              .permit(
                :title,
                :description,
                :employer_name,
                :employer_description,
                :employer_website,
                :street,
                :zipcode,
                :city,
                :remote_id,
                :permalink,
                :sector_uuid,
                :type,
                :max_candidates,
                :is_public,
                :period,
                :handicap_accessible,
                :lunch_break,
                daily_hours: {},
                coordinates: {}
              )
      end

      def update_internship_offer_params
        params.require(:internship_offer)
              .permit(
                :title,
                :description,
                :employer_name,
                :employer_description,
                :employer_website,
                :street,
                :zipcode,
                :city,
                :permalink,
                :sector_uuid,
                :max_candidates,
                :published_at,
                :is_public,
                :period,
                :lunch_break,
                :handicap_accessible,
                daily_hours: {},
                coordinates: {}
              )
      end

      def query_params
        params.permit(
          :page,
          :latitude,
          :longitude,
          :radius,
          :keyword,
          sector_ids: [],
          week_ids: []
        )
      end

      def format_internship_offers(internship_offers)
        internship_offers.map do |internship_offer|
          {
            id: internship_offer.id,
            title: internship_offer.title,
            description: internship_offer.description.to_s,
            employer_name: internship_offer.employer_name,
            url: internship_offer_url(internship_offer,
                                      query_params.merge({ utm_source: current_api_user.operator.name })),
            city: internship_offer.city.capitalize,
            date_start: I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy),
            date_end: I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy),
            latitude: internship_offer.coordinates.latitude,
            longitude: internship_offer.coordinates.longitude,
            image: view_context.asset_pack_url("media/images/sectors/#{internship_offer.sector.cover}"),
            sector: internship_offer.sector.name,
            handicap_accessible: internship_offer.handicap_accessible,
            period: internship_offer.period
          }
        end
      end

      def default_v1_params
        {
          weeks: get_weeks
        }
      end

      def get_weeks
        case params[:internship_offer][:period].to_i
        when 1
          [SchoolTrack::Seconde.first_week]
        when 2
          [SchoolTrack::Seconde.second_week]
        else
          SchoolTrack::Seconde.both_weeks.to_a.flatten
        end
      end

      def check_period_validity
        return false unless params.dig(:internship_offer, :period)

        if !(0..2).include?(params[:internship_offer][:period].to_i)
          error = { period: ['n\'est pas inclus(e) dans la liste'] }
          render_error(error: error, status: :bad_request, code: 401)
          true
        else
          false
        end
      end
    end
  end
end
