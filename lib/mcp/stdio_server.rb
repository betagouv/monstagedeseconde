#!/usr/bin/env ruby
# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'development'
require_relative '../../config/environment'
require 'mcp'

Dir[File.join(__dir__, 'tools', '*.rb')].each { |f| require f }

server = MCP::Server.new(
  name: "monstage",
  version: "1.0.0",
  instructions: "Serveur MCP pour interroger les offres de stage de Mon Stage de Seconde. " \
                "Utilisez search_offers pour chercher des offres, offer_details pour les details, " \
                "list_sectors pour les secteurs, et offer_statistics pour les statistiques.",
  tools: [
    Mcp::Tools::SearchOffers,
    Mcp::Tools::OfferDetails,
    Mcp::Tools::ListSectors,
    Mcp::Tools::OfferStatistics
  ]
)

transport = MCP::Server::Transports::StdioTransport.new(server)
transport.open
