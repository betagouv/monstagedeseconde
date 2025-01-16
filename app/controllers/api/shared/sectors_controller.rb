module Api
  module Shared
    class SectorsController < ApiBaseController
      before_action :authenticate_api_user!
      before_action :throttle_api_requests

      # lookup sectors
      def index
        render_ok(sectors: Sector.all)
      end
    end
  end
end
