module Api
  module Shared
    class CodedCraftsController < ApiBaseController
      def search
        results = Api::CodedCraft.autocomplete_by_name(
          term: keyword_params[:keyword],
          limit: keyword_params[:limit]
        )
        results = results.to_a.map(&:attributes)
        render json: results, status: :ok
      end

      private

      def keyword_params
        params.permit(:keyword, :limit)
      end
    end
  end
end
