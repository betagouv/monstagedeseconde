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
    return { etablissements: etablissements } unless body

    if JSON.parse(body).present? && JSON.parse(body)['results']
      JSON.parse(body)['results'].each do |etablissement|
        siege = etablissement['siege']
        code_ape = siege['activite_principale']
        sector = NafSectorMapping.find_sector_by_code_naf(code_ape)
        etablissements << {
          siret: siege['siret'],
          is_public: public_legal_entity?(etablissement),
          codeApe: code_ape,
          sectorId: sector&.id,
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
  rescue JSON::ParserError
    Rails.logger.error "Failed to parse API response: #{body} in ApiEntrepriseProxyController#search"
    { etablissements: [] }
  end

  private

  # La nature juridique INSEE (catégorie juridique niveau 1 == "7") identifie les
  # personnes morales de droit public. C'est la même règle que le proxy SIRET
  # (categorieJuridiqueUniteLegale.first == '7'). On garde est_service_public en
  # repli, mais recherche-entreprises le renvoie souvent à null (ex. ANCT).
  def public_legal_entity?(etablissement)
    etablissement['nature_juridique'].to_s.start_with?('7') ||
      etablissement.dig('complements', 'est_service_public') == true
  end
end
