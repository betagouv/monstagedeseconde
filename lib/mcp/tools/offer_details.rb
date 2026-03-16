# frozen_string_literal: true

module Mcp
  module Tools
    class OfferDetails < MCP::Tool
      description "Obtenir les details complets d'une offre de stage par son ID"

      input_schema(
        properties: {
          id: { type: "integer", description: "ID de l'offre de stage" }
        },
        required: ["id"]
      )

      def self.call(id:, server_context:)
        offer = InternshipOffer.kept.includes(:sector, :stats, :grades, :weeks).find(id)

        details = {
          id: offer.id,
          type: offer.type,
          title: offer.title,
          description: offer.description,
          employer_name: offer.employer_name,
          employer_description: offer.employer_description,
          employer_website: offer.employer_website,
          address: {
            street: offer.street,
            zipcode: offer.zipcode,
            city: offer.city,
            department: offer.department,
            academy: offer.academy
          },
          coordinates: {
            latitude: offer.coordinates&.lat,
            longitude: offer.coordinates&.lon
          },
          sector: offer.sector&.name,
          dates: {
            first_date: offer.first_date&.to_s,
            last_date: offer.last_date&.to_s
          },
          capacity: {
            max_candidates: offer.max_candidates,
            remaining_seats: offer.remaining_seats_count,
            total_applications: offer.total_applications_count,
            approved_applications: offer.approved_applications_count,
            submitted_applications: offer.submitted_applications_count,
            rejected_applications: offer.rejected_applications_count
          },
          grades: offer.grades.map(&:name),
          weeks: offer.weeks.map { |w| w.week_date.to_s },
          handicap_accessible: offer.handicap_accessible,
          is_public: offer.is_public,
          qpv: offer.qpv,
          rep: offer.rep,
          siret: offer.siret,
          state: offer.aasm_state,
          contact_phone: offer.contact_phone,
          lunch_break: offer.lunch_break,
          daily_hours: offer.daily_hours,
          weekly_hours: offer.weekly_hours,
          published_at: offer.published_at&.to_s
        }

        MCP::Tool::Response.new([{
          type: "text",
          text: JSON.pretty_generate(details)
        }])
      rescue ActiveRecord::RecordNotFound
        MCP::Tool::Response.new([{
          type: "text",
          text: "Offre de stage ##{id} non trouvee."
        }])
      end
    end
  end
end
