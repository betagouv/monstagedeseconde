module Api
  module Shared
    class SectorsController < ApiBaseController
      before_action :authenticate_api_user!
      before_action :throttle_api_requests_for_sectors

      # lookup sectors
      def index
        render_ok(sectors: Sector.all)
      end

      def throttle_api_requests_for_sectors
        throttle_api_requests 'sectors', InternshipOffers::Api::MAX_CALLS_PER_MINUTE
      end
    end
  end
end
