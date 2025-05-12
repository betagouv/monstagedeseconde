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
    if is_public
      fill_in 'Indiquez le nom ou le SIRET de la structure d’accueil *',
              with: '21950572400209'
      find("div.search-in-sirene ul[role='listbox'] li[role='option']").click
      find("label.fr-label[for='entreprise_is_public_true']").click
      assert Group.is_public.count.positive?
      find('#entreprise_group_id')
      select group.name,
             from: 'Type d’employeur public'
      assert_equal '219 505 724 00209', find('input#entreprise_presentation_siret').value
    else
      fill_in 'Indiquez le nom ou le SIRET de la structure d’accueil *',
              with: '909432 247 00015'
      find("div.search-in-sirene ul[role='listbox'] li[role='option']").click
      find("label.fr-label[for='entreprise_is_public_false']").click
      assert_equal '909 432 247 00015', find('input#entreprise_presentation_siret').value
    end

    select sector.name, from: "Indiquez le secteur d'activité de votre structure *" unless sector.nil?
    assert_equal 'EAST SIDE SOFTWARE', find('input#entreprise_employer_name', visible: true).value.strip
    fill_in "Indiquez le nom de l'enseigne de l'établissement d'accueil, si elle diffère de la raison sociale",
            with: is_public ? 'Mairie de Saint-Ouen-l’Aumône' : 'EAST SIDE SOFTWARE entreprise'
    fill_in 'Numéro de téléphone du dépositaire *', with: '0130131313'
  end

  def fill_in_entreprise_manual_form(group: nil, sector: nil)
    click_link('Ajouter votre structure manuellement')
    find("label.fr-label[for='entreprise_is_public_true']").click
    assert Group.is_public.count.positive?
    find('#entreprise_group_id')
    select group.name,
           from: 'Type d’employeur public'
    select sector.name, from: "Indiquez le secteur d'activité de votre structure" unless sector.nil?
    fill_in('Saisissez le nom (raison sociale) de votre établissement *', with: 'Mairie de Saint-Ouen-l’Aumône')
    fill_in "Saisissez l'adresse du siège de votre établissement *",
            with: "PLACE PIERRE MENDES FRANCE 95310 SAINT-OUEN-L'AUMONE"
  end
end
