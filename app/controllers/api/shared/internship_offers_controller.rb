# frozen_string_literal: true

module Api
  module Shared
    class InternshipOffersController < ApiBaseController
      before_action :authenticate_api_user!
      before_action :throttle_api_requests

      def index
        @internship_offers = current_api_user.personal_internship_offers.kept.order(id: :desc).page(params[:page])
        formatted_internship_offers = format_internship_offers(@internship_offers)
        data = {
          pagination: page_links,
          internshipOffers: formatted_internship_offers
        }
        render json: data, status: 200
      end

      def destroy
        internship_offer_builder.discard(instance: InternshipOffer.find_by!(remote_id: params[:id])) do |on|
          on.success(&method(:render_ok))
          on.failure(&method(:render_discard_error))
        end
      end

      private

      def internship_offer_builder
        @builder ||= Builders::InternshipOfferBuilder.new(user: current_api_user,
                                                          context: :api)
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

      def finder
        @finder ||= Finders::InternshipOfferConsumer.new(
          params: query_params,
          user: current_api_user
        )
      end

      def page_links
        {
          totalInternshipOffers: @internship_offers.total_count,
          internshipOffersPerPage: InternshipOffer::PAGE_SIZE,
          totalPages: @internship_offers.total_pages,
          currentPage: @internship_offers.current_page,
          nextPage: @internship_offers.next_page ? search_api_v1_internship_offers_url(query_params.merge({ page: @internship_offers.next_page })) : nil,
          prevPage: @internship_offers.prev_page ? search_api_v1_internship_offers_url(query_params.merge({ page: @internship_offers.prev_page })) : nil,
          isFirstPage: @internship_offers.first_page?,
          isLastPage: @internship_offers.last_page?,
          pageUrlBase: url_for(query_params.except('page'))
        }
      end

      def serialize_sector_ids(sectors)
        sectors.map { |sector_uuid| Sector.find_by(uuid: sector_uuid).id }
      end
    end
  end
end
