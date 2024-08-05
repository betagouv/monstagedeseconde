# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class ContextTypableInternshipOffer
    MAX_RADIUS_SEARCH_DISTANCE = 60_000
    delegate :next_from,
             :previous_from,
             :all,
             :all_without_page,
             to: :listable_query_builder

    def base_query
      send(mapping_user_type.fetch(user.type))
        .group(:id)
        .page(params[:page])
    end

    def base_query_without_page
      send(mapping_user_type.fetch(user.type))
        .group(:id)
    end

    private

    attr_accessor :params
    attr_reader :user, :listable_query_builder

    def initialize(user:, params:)
      @user = user
      @params = params
      @listable_query_builder = Finders::ListableInternshipOffer.new(finder: self)
    end

    def coordinate_params
      return nil unless params.key?(:latitude) || params.key?(:longitude)
      return nil if params.dig(:latitude).blank? || params.dig(:longitude).blank?

      geo_point_factory(latitude: params[:latitude], longitude: params[:longitude])
    end

    def radius_params
      return Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER unless params.key?(:radius)

      params[:radius]
    end

    def school_year_param
      return SchoolTrack::Seconde.current_year unless params.key?(:school_year)

      params[:school_year].to_i
    end

    def use_params(param_key)
      params[param_key].presence
    end

    def check_param?(param_key)
      return nil unless params.key?(param_key)
      return nil if params.dig(param_key).blank?

      true
    end

    def common_filter
      query = yield
      %i[
        keyword
        period
        sector_ids
      ].each do |sym_key|
        query = send("#{sym_key}_query", query) if use_params(sym_key)
      end
      query = hide_duplicated_offers_query(query) unless user.god?
      query = nearby_query(query) if coordinate_params
      query
    end

    def period_query(query)
      use_params(:period) ? query.merge(InternshipOffer.where(period: use_params(:period))) : query
    end

    def sector_ids_query(query)
      query.where(sector_id: use_params(:sector_ids))
    end

    def school_year_query(query)
      query.merge(InternshipOffer.with_school_year(school_year: school_year_param))
    end

    def keyword_query(query)
      query.merge(InternshipOffer.search_by_keyword(use_params(:keyword)).group(:rank))
    end

    def nearby_query(query)
      proximity_query = InternshipOffer.nearby_and_ordered(latitude: coordinate_params.latitude,
                                                           longitude: coordinate_params.longitude,
                                                           radius: radius_params)
      query.merge(proximity_query)
    end

    def hide_duplicated_offers_query(query)
      query.merge(query.where(hidden_duplicate: false))
    end

    protected

    # def weekly_framed_scopes(scope, args = nil)
    #   if args.nil?
    #     InternshipOffers::WeeklyFramed.send(scope)
    #       .or(InternshipOffers::Api.send(scope))
    #   else
    #     InternshipOffers::WeeklyFramed.send(scope, **args)
    #       .or(InternshipOffers::Api.send(scope, **args))
    #   end
    # end
  end
end
