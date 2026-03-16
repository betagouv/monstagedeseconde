# frozen_string_literal: true

module Mcp
  module Tools
    class ListSectors < MCP::Tool
      description "Lister tous les secteurs d'activite disponibles avec le nombre d'offres publiees"

      input_schema(properties: {})

      def self.call(server_context:)
        sectors = Sector.all.map do |sector|
          {
            id: sector.id,
            name: sector.name,
            offer_count: InternshipOffer.kept.published.where(sector_id: sector.id).count
          }
        end

        sectors.sort_by! { |s| -s[:offer_count] }

        MCP::Tool::Response.new([{
          type: "text",
          text: JSON.pretty_generate(sectors: sectors)
        }])
      end
    end
  end
end
