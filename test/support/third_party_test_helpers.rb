module ThirdPartyTestHelpers
  def bitly_stub
    stub_request(:post, 'https://api-ssl.bitly.com/v4/shorten')
      .with(
        body: '{"long_url":"http://example.com/dashboard/248/internship_applications/1520"}',
        headers: bitly_headers.merge({ 'Accept' => 'application/json' })
      ).to_return(default_response)
  end

  def sms_stub
    stub_request(:get, "https://europe.ipx.com/restapi/v1/sms/send?destinationAddress=33606060606&messageText=Multipliez%20vos%20chances%20de%20trouver%20un%20stage%20!%20Envoyez%20au%20moins%203%20candidatures%20sur%20notre%20site%20:%20http://example.com/c/vwb94/o%20.%20L'%C3%A9quipe%20Mon%20stage%20de%20troisieme%20&originatingAddress=Mon%20stage&originatorTON=1&password=#{ENV.fetch('LINK_MOBILITY_SECRET')}&username=#{ENV.fetch('LINK_MOBILITY_SECRET')}")
      .with(headers: bitly_headers)
      .to_return(default_response)
  end

  def sms_bitly_stub
    stub_request(:get, "https://europe.ipx.com/restapi/v1/sms/send?campaignName=&destinationAddress=33611223944&messageText=Bienvenue%20sur%20Mon%20stage%20de%202de.%20Commencez%20votre%20recherche%20ici%20:%20https://bit.ly/4athP2e&originatingAddress=MonStage2de&originatorTON=1&password=#{ENV.fetch('LINK_MOBILITY_SECRET')}&username=#{ENV.fetch('LINK_MOBILITY_SECRET')}")
      .with(headers: bitly_headers)
      .to_return(default_response)
  end

  def google_storage_stub
    stub_request(:get, 'https://storage.googleapis.com/chrome-for-testing-public/121.0.6167.184/mac-arm64/chromedriver-mac-arm64.zip')
      .with(headers: common_headers.merge({ 'Host' => 'storage.googleapis.com' })).to_return(default_response)
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
        headers: common_headers.merge({
                                        'Content-Type' => 'application/x-www-form-urlencoded',
                                        'Host' => 'oauth.piste.gouv.fr'
                                      })
      )
      .to_return(default_response)
  end

  def fim_token_stub
    stub_request(:post, ENV['FIM_URL'] + '/idp/profile/oidc/token')
      .with(
        body: {
          'client_id' => ENV['FIM_CLIENT_ID'],
          'client_secret' => ENV['FIM_CLIENT_SECRET'],
          'code' => '123456',
          'grant_type' => 'authorization_code',
          'redirect_uri' => ENV['FIM_REDIRECT_URI'],
          'scope' => 'openid stage profile email',
          'state' => 'abc',
          'nonce' => 'def'
        }
      )
      .to_return(status: 200, body: {
        'access_token' => '123456abc'
      }.to_json, headers: {})
  end

  def fim_school_manager_userinfo_stub
    stub_request(:get, ENV['FIM_URL'] + '/idp/profile/oidc/userinfo')
      .with(fim_headers)
      .to_return(status: 200, body: fim_return_body.merge({
                                                            'FrEduFonctAdm' => 'DIR',
                                                            'rne' => '0590121L',
                                                            'FrEduRneResp' => %w[
                                                              0590121L
                                                              0590121X
                                                              0590121Y
                                                              0590121Z
                                                            ]
                                                          }).to_json, headers: {})
  end

  def fim_teacher_userinfo_stub
    stub_request(:get, ENV['FIM_URL'] + '/idp/profile/oidc/userinfo')
      .with(fim_headers)
      .to_return(status: 200, body: fim_return_body.merge({
                                                            'FrEduFonctAdm' => 'ENS',
                                                            'rne' => '0590121L',
                                                            'FrEduRneResp' => %w[
                                                              0590121L
                                                              0590121X
                                                              0590121Y
                                                              0590121Z
                                                            ]
                                                          }).to_json, headers: {})
  end

  def fim_admin_userinfo_stub
    stub_request(:get, ENV['FIM_URL'] + '/idp/profile/oidc/userinfo')
      .with(fim_headers)
      .to_return(status: 200, body: fim_return_body.merge({
                                                            'FrEduFonctAdm' => 'ADF',
                                                            'rne' => '0590121L',
                                                            'FrEduRneResp' => %w[
                                                              0590121L
                                                              0590121X
                                                              0590121Y
                                                              0590121Z
                                                            ]
                                                          }).to_json, headers: {})
  end

  def fim_teacher_without_school_userinfo_stub
    stub_request(:get, ENV['FIM_URL'] + '/idp/profile/oidc/userinfo')
      .with(fim_headers)
      .to_return(status: 200, body: fim_return_body.merge({
                                                            'FrEduFonctAdm' => 'ENS',
                                                            'rne' => '0590121A',
                                                            'FrEduRneResp' => [
                                                              '0590121A'
                                                            ]
                                                          }).to_json, headers: {})
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
      .with(educonnect_header)
      .to_return(status: 200, body: File.read('test/fixtures/files/educonnect_userinfo.json'), headers: {})
  end

  def educonnect_userinfo_unknown_stub
    stub_request(:get, ENV['EDUCONNECT_URL'] + '/idp/profile/oidc/userinfo')
      .with(educonnect_header)
      .to_return(status: 200, body: File.read('test/fixtures/files/educonnect_userinfo_unknown.json'), headers: {})
  end

  def educonnect_logout_stub
    stub_request(:get, "#{ENV['EDUCONNECT_URL']}/idp/profile/oidc/logout")
      .with(
        headers: common_headers.merge({
                                        'Authorization' => 'Bearer abc123',
                                        'Host' => URI(ENV['EDUCONNECT_URL']).host
                                      })
      )
      .to_return(status: 200, body: '', headers: {})
  end

  def stub_omogen_auth
    stub_request(:post, ENV['OMOGEN_OAUTH_URL'])
      .with(
        body: { 'client_id' => ENV['OMOGEN_CLIENT_ID'], 'client_secret' => ENV['OMOGEN_CLIENT_SECRET'],
                'grant_type' => 'client_credentials' },
        headers: common_headers.merge({
                                        'Content-Type' => 'application/x-www-form-urlencoded',
                                        'Host' => URI(ENV['OMOGEN_OAUTH_URL']).host
                                      })
      ).to_return(status: 200, body: { access_token: 'token' }.to_json, headers: {})
  end

  def stub_sygne_responsible(ine:, token:)
    stub_request(:get, "#{ENV['SYGNE_URL']}/eleves/#{ine}/responsables")
      .with(headers: headers_with_token(token:, uri: URI(ENV['SYGNE_URL'])))
      .to_return(status: 200, body: File.read('test/fixtures/files/signe_responsible.json'), headers: {})
  end

  def stub_sygne_eleves(code_uai:, token:, code_mef: '10310019110', ine: '001291528AA')
    Services::Omogen::Sygne::MEFSTAT4_CODES.each do |niveau|
      expected_response = [{
        'ine' => ine,
        'nom' => 'SABABADICHETTY',
        'prenom' => 'Felix',
        'dateNaissance' => '2003-05-28',
        'codeSexe' => '1',
        'codeUai' => '0590116F',
        'anneeScolaire' => 2023,
        'niveau' => '2212',
        'libelleNiveau' => '1ERE G-T',
        'codeMef' => code_mef,
        'libelleLongMef' => 'PREMIERE GENERALE',
        'codeMefRatt' => code_mef,
        'classe' => '3E4',
        'codeRegime' => '2',
        'libelleRegime' => 'DP DAN',
        'codeStatut' => 'ST',
        'libelleLongStatut' => 'SCOLAIRE',
        'dateDebSco' => '2023-09-05',
        'adhesionTransport' => false
      }].to_json
      expected_response = [].to_json unless niveau == '2115'
      uri = URI("#{ENV['SYGNE_URL']}/etablissements/#{code_uai}/eleves?niveau=#{niveau}")
      stub_request(:get, uri).with(headers: headers_with_token(token: token, uri: uri))
                             .to_return(status: 200, body: expected_response, headers: {})
    end
  end

  def base_score_uri
    ENV['SCORE_API_URL']
  end

  def stub_score_auth_token
    uri = URI "#{base_score_uri}/login"
    body = {
      username: ENV.fetch('SCORE_API_USER'),
      password: ENV.fetch('SCORE_API_PASSWORD')
    }
    stub_request(:post, uri)
      .with(body:, headers: headers_with_host(uri: uri))
      .to_return(expected_token_response)
  end

  def stub_description_score(instance:, token: 'token', score: 0)
    stub_score_auth_token
    uri = URI("#{base_score_uri}/score")
    body = {
      employer_name: '',
      title: instance.title,
      id: 0,
      aasm_state: instance.aasm_state,
      discarded_at: nil,
      description: instance.description,
      index: 10_000,
      norma: instance.description,
      'sectors- sector_id → name': ''
    }
    stub_request(:post, uri)
      .with(body: body.to_json,
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer token',
              'Content-Type' => 'application/json',
              'Host' => 'app-66e81e7a-6b92-46f2-9e19-748407b6d99e.cleverapps.io',
              'User-Agent' => 'Ruby'
            })
      .to_return(status: 200, body: { score: score }.to_json, headers: {})
  end

  def stub_admin_login
    stub_request(:get, ENV['FIM_URL'] + '/idp/profile/oidc/token')
      .with(fim_headers)
      .to_return(status: 200, body: { access_token: 'token' }.to_json, headers: {})
  end

  private

  def bitly_headers
    build_headers(
      'Authorization' => 'Bearer ',
      'Content-Type' => 'application/json',
      'User-Agent' => 'Ruby Bitly/2.0.1'
    )
  end

  def bitly_headers
    {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Host' => 'europe.ipx.com',
      'User-Agent' => 'Ruby'
    }
  end

  def common_headers
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Ruby'
    }
  end

  def build_headers(custom_headers = {})
    common_headers.merge(custom_headers)
  end

  def expected_token_response(token: 'token')
    default_response.merge(body: { access_token: token }.to_json)
  end

  def headers_with_token(token:, uri:)
    headers_with_host(uri: uri).merge({
                                        'Authorization' => "Bearer #{token}",
                                        'Compression-Zip' => 'non'
                                      })
  end

  def headers_with_host(uri:)
    common_headers.merge({ 'Host' => URI(uri).host })
  end

  def fim_headers
    {
      headers: {
        'Authorization' => 'Bearer 123456abc',
        'Content-Type' => 'application/json'
      }
    }
  end

  def educonnect_header
    {
      headers: {
        'Authorization' => 'Bearer token_educonnect',
        'Content-Type' => 'application/json'
      }
    }
  end

  def default_response
    { status: 200, body: '', headers: {} }
  end

  def fim_return_body
    { 'given_name' => 'Jean',
      'family_name' => 'Dupont',
      'email' => 'jean.dupont@ac-lille.fr' }
  end

  def stub_request_with(method, url, headers:, response:, body: nil)
    stub_request(method, url)
      .with(body: body, headers: headers)
      .to_return(response)
  end
end
