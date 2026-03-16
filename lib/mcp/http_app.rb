# frozen_string_literal: true

require 'mcp'

Dir[File.join(__dir__, 'tools', '*.rb')].each { |f| require f }

module Mcp
  class HttpApp
    MCP_TOKEN_HEADER = 'HTTP_X_MCP_TOKEN'

    def initialize
      @server = MCP::Server.new(
        name: "1eleve1stage",
        version: "1.0.0",
        instructions: "Serveur MCP pour interroger les offres de stage de 1élève1stage. " \
                      "Utilisez search_offers pour chercher des offres, offer_details pour les details, " \
                      "list_sectors pour les secteurs, et offer_statistics pour les statistiques.",
        tools: [
          Mcp::Tools::SearchOffers,
          Mcp::Tools::OfferDetails,
          Mcp::Tools::ListSectors,
          Mcp::Tools::OfferStatistics
        ]
      )
      @transport = MCP::Server::Transports::StreamableHTTPTransport.new(@server, stateless: true)
      @server.transport = @transport
    end

    def call(env)
      request = Rack::Request.new(env)
      status, headers, body = @transport.handle_request(request)

      # Disable gzip compression — Rack::Deflater chokes on streaming bodies
      headers['Content-Encoding'] = 'identity'
      # Wrap body to ensure it responds to #each (Rack spec)
      body = [body.to_s] unless body.respond_to?(:each)

      [status, headers, body]
    end
  end
end
