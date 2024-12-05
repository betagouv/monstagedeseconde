module EntrepriseFormFiller
  def fill_in_entreprise_form(group: nil, sector: nil)
    body = File.read(
      Rails.root.join(
        *%w[test
            fixtures
            files
            api-insee-mairie-st-ouen.json]
      )
    )
    stub_request(:get, 'https://api.insee.fr/entreprises/sirene/siret/21950572400209')
      .with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Bearer TOKEN',
          'Content-Type' => 'application/json',
          'Host' => 'api.insee.fr',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body:, headers: {})

    stub_request(:post, 'https://api.insee.fr/token')
      .with(
        body: { 'grant_type' => 'client_credentials' },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => "Basic #{ENV['API_SIRENE_SECRET']}",
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Host' => 'api.insee.fr',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: { access_token: 'TOKEN' }.to_json, headers: {})
    fill_in 'Indiquez le nom ou le SIRET de la structure d’accueil *',
            with: '21950572400209'
    find("div.search-in-sirene ul[role='listbox'] li[role='option']").click
    find("label.fr-label[for='entreprise_is_public_true']").click
    assert Group.is_public.count.positive?
    find('#entreprise_group_id')
    select group.name,
           from: 'Type d’employeur public'
    select sector.name, from: "Secteur d'activité" unless sector.nil?
    assert_equal '219 505 724 00209',  find('input#entreprise_presentation_siret').value
    assert_equal 'COMMUNE DE SAINT OUEN L AUMONE', find('input#entreprise_employer_name').value.strip
    fill_in "Indiquez le nom de l'enseigne de l'établissement d'accueil, si elle diffère de la raison sociale",
            with: 'Mairie de Saint-Ouen-l’Aumône'
    fill_in 'Numéro de téléphone du dépositaire *', with: '0130131313'
  end
end
