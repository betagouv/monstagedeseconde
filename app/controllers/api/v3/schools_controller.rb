module Api
  module V3
    # Search school by city
    class SchoolsController < Api::Shared::SchoolsController
      include Api::JsonApiRenderable

      def search
        render_jsonapi_resource(
          type: 'school-search-result',
          record: {
            id: 'search',
            matches: result
          }
        )
      end

      def nearby
        schools = School.nearby(latitude: params[:latitude], longitude: params[:longitude], radius: 60_000)
        render_jsonapi_collection(
          type: 'school',
          records: schools.map { |school| school.attributes.symbolize_keys },
          meta: {
            latitude: params[:latitude],
            longitude: params[:longitude]
          }
        )
      end
    end
  end
end
