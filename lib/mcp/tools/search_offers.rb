# frozen_string_literal: true

module Mcp
  module Tools
    class SearchOffers < MCP::Tool
      description "Rechercher des offres de stage par mot-cle, localisation, secteur, departement ou niveau scolaire"

      input_schema(
        properties: {
          keyword: { type: "string", description: "Mot-cle pour la recherche full-text (titre, description, employeur)" },
          department: { type: "string", description: "Nom du departement (ex: 'Paris', 'Gironde')" },
          sector_id: { type: "integer", description: "ID du secteur d'activite" },
          latitude: { type: "number", description: "Latitude pour recherche geographique" },
          longitude: { type: "number", description: "Longitude pour recherche geographique" },
          radius: { type: "integer", description: "Rayon de recherche en metres (defaut: 60000)" },
          grade: { type: "string", enum: %w[seconde troisieme], description: "Niveau scolaire" },
          only_with_seats: { type: "boolean", description: "Uniquement les offres avec des places disponibles (defaut: true)" },
          page: { type: "integer", description: "Numero de page (defaut: 1)" },
          per_page: { type: "integer", description: "Resultats par page, max 50 (defaut: 20)" }
        }
      )

      def self.call(server_context:, **args)
        query = InternshipOffer.kept.published

        query = query.search_by_keyword(args[:keyword]) if args[:keyword].present?
        query = query.by_department(args[:department]) if args[:department].present?
        query = query.by_sector(args[:sector_id]) if args[:sector_id].present?
        query = query.with_seats if args.fetch(:only_with_seats, true)

        if args[:latitude].present? && args[:longitude].present?
          radius = args[:radius] || Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER
          query = query.nearby(latitude: args[:latitude], longitude: args[:longitude], radius: radius)
        end

        case args[:grade]
        when "seconde"
          query = query.seconde
        when "troisieme"
          query = query.troisieme_or_quatrieme
        end

        per_page = [args.fetch(:per_page, 20).to_i, 50].min
        page = args.fetch(:page, 1).to_i
        results = query.includes(:sector, :stats, :grades).page(page).per(per_page)

        offers = results.map do |offer|
          {
            id: offer.id,
            title: offer.title,
            employer_name: offer.employer_name,
            city: offer.city,
            zipcode: offer.zipcode,
            department: offer.department,
            sector: offer.sector&.name,
            first_date: offer.first_date&.to_s,
            last_date: offer.last_date&.to_s,
            remaining_seats: offer.remaining_seats_count,
            max_candidates: offer.max_candidates,
            grades: offer.grades.map(&:name),
            handicap_accessible: offer.handicap_accessible
          }
        end

        MCP::Tool::Response.new([{
          type: "text",
          text: JSON.pretty_generate(
            total: results.total_count,
            page: page,
            per_page: per_page,
            offers: offers
          )
        }])
      end
    end
  end
end
