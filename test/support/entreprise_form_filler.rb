module EntrepriseFormFiller
  def fill_in_entreprise_form(group: nil, sector: nil, is_public: true)
    body = File.read(
      Rails.root.join(
        *%w[test
            fixtures
            files
            api-insee-mairie-st-ouen.json]
      )
    )
    # API Sirene 3.11 (clé statique X-INSEE-Api-Key-Integration, plus de jeton OAuth)
    stub_request(:get, 'https://api.insee.fr/api-sirene/3.11/siret/21950572400209')
      .to_return(status: 200, body:, headers: {})
    body = File.read(
      Rails.root.join(
        *%w[test
            fixtures
            files
            api-insee-adresse-east-side-software.json]
      )
    )
    stub_request(:get, 'https://api.insee.fr/api-sirene/3.11/siret/90943224700015')
      .to_return(status: 200, body:, headers: {})
    if is_public
      fill_in 'entreprise_siren', with: '21950572400209'
      find("div.search-in-sirene ul[role='listbox'] li[role='option']").click
      find("label.fr-label[for='entreprise_is_public_true']").click
      assert Group.is_public.count.positive?
      find('#group-choice')
      select group.name, from: 'group-choice'
      assert_equal '219 505 724 00209', find('input#entreprise_presentation_siret').value
    else
      fill_in 'entreprise_siren', with: '909432 247 00015'
      find("div.search-in-sirene ul[role='listbox'] li[role='option']").click
      find("label.fr-label[for='entreprise_is_public_false']").click
      assert_equal '909 432 247 00015', find('input#entreprise_presentation_siret').value
    end

    select sector.name, from: 'entreprise_sector_id' unless sector.nil?
    expected_employer_name = is_public ? 'COMMUNE DE SAINT OUEN L AUMONE' : 'EAST SIDE SOFTWARE'
    assert_equal expected_employer_name, find('input#entreprise_employer_name', visible: true).value.strip
    fill_in "Indiquez le nom de l'enseigne de l'établissement d'accueil, si elle diffère de la raison sociale",
            with: is_public ? 'Mairie de Saint-Ouen-l’Aumône' : 'EAST SIDE SOFTWARE entreprise'
    fill_in 'Numéro de téléphone du dépositaire *', with: '0130131313'
  end

  def fill_in_entreprise_manual_form(group: nil, sector: nil)
    # En saisie manuelle, l'adresse est géocodée côté serveur via Nominatim : on le stube.
    stub_request(:get, %r{nominatim\.openstreetmap\.org/search})
      .to_return(
        status: 200,
        body: [{
          address: { road: 'PLACE PIERRE MENDES FRANCE', postcode: '95310',
                     city: "SAINT-OUEN-L'AUMONE", country: 'France' },
          lat: '49.0438', lon: '2.0966',
          display_name: "PLACE PIERRE MENDES FRANCE, 95310 SAINT-OUEN-L'AUMONE, France",
          name: "SAINT-OUEN-L'AUMONE"
        }].to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    click_link('Ajouter votre structure manuellement')
    find("label.fr-label[for='entreprise_is_public_true']").click
    assert Group.is_public.count.positive?
    find('#group-choice')
    select group.name, from: 'group-choice'
    select sector.name, from: 'entreprise_sector_id' unless sector.nil?
    fill_in('Saisissez le nom (raison sociale) de votre établissement *', with: 'Mairie de Saint-Ouen-l’Aumône')
    fill_in "Saisissez l'adresse du siège de votre établissement *",
            with: "PLACE PIERRE MENDES FRANCE 95310 SAINT-OUEN-L'AUMONE"
  end
end
