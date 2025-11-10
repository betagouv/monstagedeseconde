# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiSireneProxyController < ApplicationController
  include Api::Throttle
  include Siretable
  MAX_REQUESTS_PER_MINUTE = 50 * 60 # 50 requests per second
  before_action :throttle_api_requests_for_siret

  def search
    response = Api::AutocompleteSirene.search_by_siret(siret: params[:siret])
    render json: clean_response(response.body), status: response.code
  end

  def throttle_api_requests_for_siret
    site_throttle_api_requests 'siret', MAX_REQUESTS_PER_MINUTE
  end

  def clean_response(body)
    if JSON.parse(body)['etablissement']
      etablissement_json = JSON.parse(body)['etablissement']
      etablissement = {
        siret: etablissement_json['siret'],
        is_public: etablissement_json['uniteLegale']['categorieJuridiqueUniteLegale'].first == '7',
        codeApe: etablissement_json['uniteLegale']['activitePrincipaleUniteLegale'],
        uniteLegale: {
          denominationUniteLegale: etablissement_json['uniteLegale']['denominationUniteLegale']
        },
        adresseEtablissement: {
          numeroVoieEtablissement: etablissement_json['adresseEtablissement']['numeroVoieEtablissement'],
          typeVoieEtablissement: etablissement_json['adresseEtablissement']['typeVoieEtablissement'],
          libelleVoieEtablissement: "#{etablissement_json['adresseEtablissement']['numeroVoieEtablissement']} #{etablissement_json['adresseEtablissement']['typeVoieEtablissement']} #{etablissement_json['adresseEtablissement']['libelleVoieEtablissement']}",
          codePostalEtablissement: etablissement_json['adresseEtablissement']['codePostalEtablissement'],
          libelleCommuneEtablissement: etablissement_json['adresseEtablissement']['libelleCommuneEtablissement'],
          adresseCompleteEtablissement: "#{etablissement_json['adresseEtablissement']['numeroVoieEtablissement']} #{etablissement_json['adresseEtablissement']['typeVoieEtablissement']} #{etablissement_json['adresseEtablissement']['libelleVoieEtablissement']} #{etablissement_json['adresseEtablissement']['codePostalEtablissement']} #{etablissement_json['adresseEtablissement']['libelleCommuneEtablissement']}"
        }
      }
    end
    { etablissement: etablissement }
  end
end

