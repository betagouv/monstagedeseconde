module ThirdPartyTestHelpers
  def bitly_stub
    stub_request(:post, 'https://api-ssl.bitly.com/v4/shorten')
      .with(
        body: '{"long_url":"http://example.com/dashboard/248/internship_applications/1520"}',
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Bearer ',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby Bitly/2.0.1'
        }
      )
      .to_return(status: 200, body: '', headers: {})
  end

  def sms_stub
    stub_request(:get, "https://europe.ipx.com/restapi/v1/sms/send?destinationAddress=33606060606&messageText=Multipliez%20vos%20chances%20de%20trouver%20un%20stage%20!%20Envoyez%20au%20moins%203%20candidatures%20sur%20notre%20site%20:%20http://example.com/c/vwb94/o%20.%20L'%C3%A9quipe%20Mon%20stage%20de%20troisieme%20&originatingAddress=Mon%20stage&originatorTON=1&password=#{ENV.fetch('LINK_MOBILITY_SECRET')}&username=#{ENV.fetch('LINK_MOBILITY_SECRET')}")
      .with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'europe.ipx.com',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: '', headers: {})
  end

  def sms_bitly_stub
    stub_request(:get, "https://europe.ipx.com/restapi/v1/sms/send?campaignName=&destinationAddress=33611223944&messageText=Bienvenue%20sur%20Mon%20stage%20de%202de.%20Commencez%20votre%20recherche%20ici%20:%20https://bit.ly/4athP2e&originatingAddress=MonStage2de&originatorTON=1&password=#{ENV.fetch('LINK_MOBILITY_SECRET')}&username=#{ENV.fetch('LINK_MOBILITY_SECRET')}")
      .with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'europe.ipx.com',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: '', headers: {})
  end

  def google_storage_stub
    stub_request(:get, 'https://storage.googleapis.com/chrome-for-testing-public/121.0.6167.184/mac-arm64/chromedriver-mac-arm64.zip')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'storage.googleapis.com',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: '', headers: {})
  end

  def captcha_stub
    stub_request(:post, 'https://oauth.piste.gouv.fr/api/oauth/token')
      .with(
        body: {
          'client_id' => ENV['CAPTCHA_CLIENT_ID'],
          'client_secret' => ENV['CAPTCHA_CLIENT_SECRET'],
          'grant_type' => 'client_credentials',
          'scope' => 'piste.captchetat'
        },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Host' => 'oauth.piste.gouv.fr',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: '', headers: {})
  end

  def fim_token_stub(code)
    stub_request(:post, 'https://hub-pr2.phm.education.gouv.fr/idp/profile/oidc/token')
      .with(
        body: {
          'client_id' => ENV['FIM_CLIENT_ID'],
          'client_secret' => ENV['FIM_CLIENT_SECRET'],
          'code' => code,
          'grant_type' => 'authorization_code',
          'redirect_uri' => ENV['FIM_REDIRECT_URI'],
          'scope' => 'openid stage profile email',
          'state' => /.*/,
          'nonce' => /.*/
        },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Host' => 'hub-pr2.phm.education.gouv.fr',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: {
        'access_token' => '123456abc'
      }.to_json, headers: {})
  end

  def fim_school_manager_userinfo_stub
    stub_request(:get, ENV['FIM_URL'] + '/idp/profile/oidc/userinfo')
      .with(
        headers: {
          'Authorization' => 'Bearer 123456abc',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: {
        'FrEduFonctAdm' => 'DIR',
        'given_name' => 'Jean',
        'family_name' => 'Dupont',
        'email' => 'jean.dupont@ac-lille.fr',
        'rne' => '0590121L'
      }.to_json, headers: {})
  end

  def fim_teacher_userinfo_stub
    stub_request(:get, ENV['FIM_URL'] + '/idp/profile/oidc/userinfo')
      .with(
        headers: {
          'Authorization' => 'Bearer 123456abc',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: {
        'FrEduFonctAdm' => 'ENS',
        'given_name' => 'Jean',
        'family_name' => 'Dupont',
        'email' => 'jean.dupont@ac-lille.fr',
        'rne' => '0590121L'
      }.to_json, headers: {})
  end

  def fim_admin_userinfo_stub
    stub_request(:get, ENV['FIM_URL'] + '/idp/profile/oidc/userinfo')
      .with(
        headers: {
          'Authorization' => 'Bearer 123456abc',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: {
        'FrEduFonctAdm' => 'ADF',
        'given_name' => 'Jean',
        'family_name' => 'Dupont',
        'email' => 'jean.dupont@ac-lille.fr',
        'rne' => '0590121L'
      }.to_json, headers: {})
  end

  def fim_teacher_without_school_userinfo_stub
    stub_request(:get, ENV['FIM_URL'] + '/idp/profile/oidc/userinfo')
      .with(
        headers: {
          'Authorization' => 'Bearer 123456abc',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: {
        'FrEduFonctAdm' => 'ENS',
        'given_name' => 'Jean',
        'family_name' => 'Dupont',
        'email' => 'jean.dupont@ac-lille.fr',
        'rne' => '0590121X'
      }.to_json, headers: {})
  end

  def prismic_stub(body_content)
    headers = {
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent': 'Ruby'
    }
    stub_request(:get, "#{ENV.fetch('PRISMIC_URL')}?access_token=#{ENV.fetch('PRISMIC_API_KEY')}")
      .with(headers: headers)
      .to_return(status: 200, body: body_content, headers: {})
  end

  def prismic_straight_stub(&block)
    PagesController.stub_any_instance(:get_resources, []) do
      PagesController.stub_any_instance(:get_faqs, [], &block)
    end
  end

  def educonnect_token_stub
    stub_request(:post, ENV['EDUCONNECT_URL'] + '/idp/profile/oidc/token')
      .with(
        body: {
          'client_id' => ENV['EDUCONNECT_CLIENT_ID'],
          'client_secret' => ENV['EDUCONNECT_CLIENT_SECRET'],
          'code' => '123456',
          'grant_type' => 'authorization_code',
          'redirect_uri' => ENV['EDUCONNECT_REDIRECT_URI'],
          'state' => 'abc',
          'nonce' => 'def'
        }
      )
      .to_return(status: 200, body: File.read('test/fixtures/files/educonnect_token.json'), headers: {})
  end

  def educonnect_userinfo_stub
    stub_request(:get, ENV['EDUCONNECT_URL'] + '/idp/profile/oidc/userinfo')
      .with(
        headers: {
          'Authorization' => 'Bearer token_educonnect',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: File.read('test/fixtures/files/educonnect_userinfo.json'), headers: {})
  end

  def educonnect_userinfo_unknown_stub
    stub_request(:get, ENV['EDUCONNECT_URL'] + '/idp/profile/oidc/userinfo')
      .with(
        headers: {
          'Authorization' => 'Bearer token_educonnect',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: File.read('test/fixtures/files/educonnect_userinfo_unknown.json'), headers: {})
  end

  def stub_omogen_auth
    stub_request(:post, ENV['OMOGEN_OAUTH_URL'])
      .with(
        body: { 'client_id' => ENV['OMOGEN_CLIENT_ID'], 'client_secret' => ENV['OMOGEN_CLIENT_SECRET'],
                'grant_type' => 'client_credentials' },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Host' => URI(ENV['OMOGEN_OAUTH_URL']).host,
          'User-Agent' => 'Ruby'
        }
      ).to_return(status: 200, body: { token: 'token' }.to_json, headers: {})
  end

  def stub_sygne_reponsible(ine)
    expected_response =
      [
        { nomFamille: 'BADEZ',
          prenom: 'Claudette',
          email: 'O*************@email.co',
          telephonePersonnel: '0405060708',
          adrResidenceResp: { adresseLigne1: '4, rue du Muguet',
                              adresseLigne2: 'Le Banel',
                              codePostal: '12110',
                              libelleCommune: 'AUBIN' },
          address: '4, rue du Muguet, Le Banel 12110 AUBIN',
          codeNiveauResponsabilite: '3',
          codeCivilite: 'F' },
        { nomFamille: 'CHIERICI',
          prenom: 'Frederic',
          email: 'I*************@email.co',
          telephonePersonnel: '0506070809',
          adrResidenceResp: { adresseLigne1: '4, rue du Muguet',
                              adresseLigne2: 'Le Banel',
                              codePostal: '12110',
                              libelleCommune: 'AUBIN' },
          codeNiveauResponsabilite: '1',
          codeCivilite: 'F' },
        { nomFamille: 'GROHIN',
          prenom: 'Juliette',
          email: 'G*************@email.co',
          adrResidenceResp: { adresseLigne1: '4, rue du Muguet',
                              adresseLigne2: 'Le Banel',
                              codePostal: '12110',
                              libelleCommune: 'AUBIN' },
          telephonePersonnel: '0506070819',
          codeNiveauResponsabilite: '1',
          codeCivilite: 'M' }
      ].to_json
    stub_request(:get, "#{ENV['SYGNE_URL']}/eleves/#{ine}/responsables")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Bearer',
          'Compression-Zip' => 'non',
          'Host' => URI(ENV['SYGNE_URL']).host,
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: expected_response, headers: {})
  end
end
