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
      @companies = filtered_companies(parameters)
    end
  end

  def show
    @company = params
    @company.merge!(contact_message: Company.contact_message)
  end

  def contact
    if Services::SendContactImmersionFacilite.new(params).perform
      redirect_to recherche_entreprises_path, notice: 'Votre message a bien été envoyé'
    else
      redirect_to recherche_entreprises_path, alert: "Une erreur est survenue lors de l'envoi de votre message"
    end
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
    while iteration < 3 && @companies.to_a.count.zero?
      @level_name, sibling_coded_crafts = coded_craft.siblings(level: iteration)
      sibling_coded_crafts_codes = sibling_coded_crafts.pluck(:ogr_code)
      break if sibling_coded_crafts_codes.count > MAXIMUM_CODES_IN_LIST

      parameters.merge!(appellation_codes: sibling_coded_crafts_codes)
      @companies = filtered_companies(parameters)
      iteration += 1
    end
    [@level_name, @companies]
  end

  def filtered_companies(parameters)
    companies = fetch_companies(parameters)
    companies = reject_missing_location_id_and_wrong_contact_mode(companies)
    reject_companies_with_offers(companies)
  end

  def reject_missing_location_id_and_wrong_contact_mode(companies)
    companies.reject { |company| company['locationId'].blank? || company['contactMode'] != 'EMAIL' }
  end

  def reject_companies_with_offers(companies)
    sirets_in_base = internship_offers_sirets(companies)
    companies.reject { |company| company['siret'].in?(sirets_in_base) }
  end

  def internship_offers_sirets(companies)
    companies_siret = companies.map { |company| company['siret'] }
    InternshipOffers::WeeklyFramed.kept
                                  .where(siret: companies_siret)
                                  .pluck(:siret)
                                  .uniq
  end
end
