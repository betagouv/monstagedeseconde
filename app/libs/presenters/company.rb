module Presenters
  class Company

    def immersion_facilitee_url
      params_hash = {
        siret: siret,
        location: location_id,
        appellationCode: appellation_code,
        mtm_campaign: 'ms2e'
      }
      "https://immersion-facile.beta.gouv.fr/offre?#{params_hash.to_query}"
    end

    def company_url
      Rails.application.routes.url_helpers.company_path(
        siret: siret,
        id: location_id,
        appellation_code: appellation_code,
        address: address,
        name: name,
        appelation_name: appelation_name,
        naf_label: naf_label
      )
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
