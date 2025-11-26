# frozen_string_literal: true

class GeocodeInternshipOffersJob < ActiveJob::Base
  queue_as :data_import

  def perform
    Rails.application.load_tasks
    Rake::Task['data_migrations:geocode_internship_offers_entreprise_coordinates'].invoke
    Rake::Task['data_migrations:geocode_internship_offers_entreprise_coordinates'].reenable
  end
end

