# frozen_string_literal: true

module Mcp
  module Tools
    class OfferStatistics < MCP::Tool
      description "Obtenir des statistiques agregees sur les offres de stage (par departement, secteur ou academie)"

      input_schema(
        properties: {
          group_by: {
            type: "string",
            enum: %w[department sector academy],
            description: "Dimension d'agregation"
          },
          department: { type: "string", description: "Filtrer par departement (optionnel)" },
          school_year: { type: "integer", description: "Annee scolaire (optionnel, ex: 2025)" }
        },
        required: ["group_by"]
      )

      def self.call(group_by:, server_context:, **args)
        query = Reporting::InternshipOffer.kept
          .joins("INNER JOIN internship_offer_stats ON internship_offer_stats.internship_offer_id = internship_offers.id")

        if args[:school_year].present?
          school_year = SchoolYear::Floating.new_by_year(year: args[:school_year].to_i)
          query = query.during_year(school_year: school_year)
        end

        if args[:department].present?
          query = query.by_department(department: args[:department])
        end

        aggregate_select = Reporting::InternshipOffer.aggregate_functions_to_sql_select

        results = case group_by
        when "department"
          query.select("department", *aggregate_select)
               .group(:department)
               .order(:department)
               .map do |row|
            {
              department: row.department,
              total_offers: row.total_report_count.to_i,
              total_applications: row.total_applications_count.to_i,
              approved_applications: row.approved_applications_count.to_i
            }
          end
        when "sector"
          query.select("sector_id", *aggregate_select)
               .includes(:sector)
               .group(:sector_id)
               .order(:sector_id)
               .map do |row|
            {
              sector: row.sector&.name,
              total_offers: row.total_report_count.to_i,
              total_applications: row.total_applications_count.to_i,
              approved_applications: row.approved_applications_count.to_i
            }
          end
        when "academy"
          query.select("academy", *aggregate_select)
               .group(:academy)
               .order(:academy)
               .map do |row|
            {
              academy: row.academy,
              total_offers: row.total_report_count.to_i,
              total_applications: row.total_applications_count.to_i,
              approved_applications: row.approved_applications_count.to_i
            }
          end
        end

        summary = {
          total_offers: results.sum { |r| r[:total_offers] },
          total_applications: results.sum { |r| r[:total_applications] },
          total_approved: results.sum { |r| r[:approved_applications] }
        }

        MCP::Tool::Response.new([{
          type: "text",
          text: JSON.pretty_generate(
            summary: summary,
            group_by: group_by,
            data: results
          )
        }])
      end
    end
  end
end
