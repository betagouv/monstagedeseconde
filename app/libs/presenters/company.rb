module Presenters
  class Company

    def immersion_facilitee_url
      params_hash = {
        siret: siret,
        location: location_id,
        appellationCode: appellation_code,
        mtm_campaign: 'ms2de'
      }
      "https://immersion-facile.beta.gouv.fr/offre?#{params_hash.to_query}"
    end

    attr_reader :company, :siret, :appellation_code, :location_id

    private

    def initialize(company)
      @company = company
      @siret = company['siret']
      @appellation_code = company.dig('appellations', 0, 'appellationCode')
      @location_id = company['locationId']
    end
  end
end
