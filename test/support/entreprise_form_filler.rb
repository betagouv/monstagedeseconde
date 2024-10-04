module EntrepriseFormFiller
  def fill_in_entreprise_form(group: nil, sector: nil)
    body = File.read(
      Rails.root.join(
        *%w[test
            fixtures
            files
            api-insee-adresse-east-side-software.json]
      )
    )
    stub_request(:get, 'https://api.insee.fr/entreprises/sirene/siret/90943224700015')
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
    fill_in 'Indiquez le nom ou le SIRET de la structure d’accueil*',
            with: '90943224700015'
    find("div.search-in-sirene ul[role='listbox'] li[role='option']").click
    find("label.fr-label[for='entreprise_is_public_true']").click
    assert Group.is_public.count.positive?
    find('#entreprise_group_id')
    select group.name,
           from: 'Type d’employeur public'
    select sector.name, from: "Secteur d'activité"
    assert_equal '909 432 247 00015',  find('input#entreprise_presentation_siret').value
    assert_equal 'EAST SIDE SOFTWARE', find('input#entreprise_employer_name').value.strip
    fill_in "Indiquez le nom de l'enseigne de l'établissement d'accueil, si elle diffère de la raison sociale",
            with: 'East Side Software-Paris'
  end
end
