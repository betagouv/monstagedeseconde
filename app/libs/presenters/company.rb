module Presenters
  class Company
    def immersion_facilitee_url
      params_hash = {
        siret:,
        location: location_id,
        appellationCode: appellation_code,
        mtm_campaign: 'ms2e'
      }
      "https://immersion-facile.beta.gouv.fr/offre?#{params_hash.to_query}"
    end

    def company_url
      Rails.application.routes.url_helpers.company_path(
        siret:,
        id: location_id,
        appellation_code:,
        address:,
        name:,
        appelation_name:,
        naf_label:
      )
    end

    def contact_message
      Company.contact_message(with_carriage_return: true)
    end

    attr_reader :company, :siret, :appellation_code, :location_id, :address, :appelation_name, :name, :naf_label

    private

    def initialize(company)
      @company = company
      @siret = company['siret']
      @appellation_code = company.dig('appellations', 0, 'appellationCode')
      @location_id = company['locationId']
      @name = company['name']
      @appelation_name = company.dig('appellations', 0, 'appellationLabel')
      @address = "#{company['address']['streetNumberAndAddress']}, #{company['address']['postcode']} #{company['address']['city']}"
      @naf_label = company['nafLabel']
    end
  end
end
