module Api
  module V3
    class SectorsController < Api::Shared::SectorsController
      include Api::AuthV2
      include Api::JsonApiRenderable

      def index
        sectors = Sector.all
        render_jsonapi_collection(
          type: 'sector',
          records: sectors.map { |sector| sector.attributes.symbolize_keys }
        )
      end
    end
  end
end
