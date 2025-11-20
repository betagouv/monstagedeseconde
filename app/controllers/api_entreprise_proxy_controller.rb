# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiEntrepriseProxyController < ApplicationController
  include Siretable
  
  def search
    return render json: { error: 'missing name param' }, status: 400 unless params[:name]

    response = Api::AutocompleteSirene.search_by_name(name: params[:name])
    render json: clean_response(response.body), status: response.code
  end

  def clean_response(body)
    etablissements = []
    if JSON.parse(body)['results']
      JSON.parse(body)['results'].each do |etablissement|
        siege = etablissement['siege']
        etablissements << {
          siret: siege['siret'],
          is_public: etablissement['complements']['est_service_public'] == true,
          codeApe: siege['activite_principale'],
          uniteLegale: {
            denominationUniteLegale: etablissement['nom_complet']
          },
          adresseEtablissement: {
            numeroVoieEtablissement: '',
            typeVoieEtablissement: '',
            libelleVoieEtablissement: "#{siege['numero_voie']} #{siege['type_voie']} #{siege['libelle_voie']}",
            codePostalEtablissement: siege['commune'],
            libelleCommuneEtablissement: siege['libelle_commune'],
            adresseCompleteEtablissement: "#{siege['adresse']}"
          }
        }
      end
    end
    { etablissements: etablissements }
  end
end
