class CompaniesController < ApplicationController
  layout 'search', only: :index

  DEFAULT_RADIUS_IN_KM = 10
  MAXIMUM_CODES_IN_LIST = 70

  def index
    @companies    = []
    @level_name   = ''
    parameters = {
      latitude: search_params[:latitude].presence,
      longitude: search_params[:longitude].presence,
      radius_in_km: search_params[:radius_in_km].presence || DEFAULT_RADIUS_IN_KM
    }
    @appellation_code = search_params[:appellationCode].presence
    if @appellation_code.present?
      @level_name, @companies = fetch_companies_by_appellation_code(parameters)
    else
      @companies = reject_missing_location_id fetch_companies(parameters)
    end
  end

  def show
    puts "Params: #{params}"
    # create stub object 

    
    @company = params
    @company.merge!(contact_message: contact_message)
    #   siret: params[:siret], 
    #   id: params[:id], appellation_code: params[:appellation_code], address: params[:address], name: params[:name], appelation_name: params[:appelation_name] }
    # @company = Presenters::Company.new(company)
  end

  def contact
    # send contact message to company
    Services::SendContactImmersionFacilite.new(params).perform
  end

  private

  def search_params
    params.permit(:city,
                  :latitude,
                  :longitude,
                  :radius_in_km,
                  :appellationCode,
                  :keyword)
  end

  def fetch_companies(parameters)
    return [] if parameters[:latitude].blank? || parameters[:longitude].blank?

    Services::ImmersionFacile.new(**parameters).perform
  end

  def fetch_companies_by_appellation_code(parameters)
    @level_name = ''
    iteration = 0
    coded_craft = CodedCraft.fetch_coded_craft(@appellation_code)
    while iteration < 3 && @companies.to_a.count.zero? do
      @level_name, sibling_coded_crafts = coded_craft.siblings(level: iteration)
      sibling_coded_crafts_codes = sibling_coded_crafts.pluck(:ogr_code)
      break if sibling_coded_crafts_codes.count > MAXIMUM_CODES_IN_LIST
      parameters.merge!(appellation_codes: sibling_coded_crafts_codes)
      @companies = reject_missing_location_id(fetch_companies(parameters))
      iteration += 1
    end
    [@level_name, @companies]
  end

  def reject_missing_location_id(companies)
    companies.reject { |company| company['locationId'].blank? }
  end

  def contact_message
    "Bonjour,J’ai identifié votre entreprise sur le module Stages de 2de générale et technologique "\
    "du ministère de l’éducation nationale (plateforme 1 jeune 1 solution). Immersion Facilitée a "\
    "en effet signalé que vous êtes disposés à accueillir des élèves de seconde générale et "\
    "technologique pour leur séquence d’observation en milieu professionnel entre le 17 et "\
    "le 28 juin 2024.***Rédigez ici votre email de motivation.***Pourriez-vous me contacter "\
    "par mail ou par téléphone pour échanger sur mon projet de découverte de vos métiers ? "\
    "Vous trouverez sur cet URL le modèle de convention à utiliser : "\
    "https://www.education.gouv.fr/sites/default/files/ensel643_annexe1.pdf "\
    "Avec mes remerciements anticipés."
  end
end