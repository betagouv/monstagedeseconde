require 'test_helper'

module Services
  class ImmersionFacileTest < ActiveSupport::TestCase
    def headers
      {
        'Accept'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>ENV['IMMERSION_FACILE_API_KEY'],
        'Host'=>'staging.immersion-facile.beta.gouv.fr',
        'User-Agent'=>'Ruby'
      }
    end

    def parameters(latitude: 48.8566, longitude: 2.3522, radius_in_km: 10)
      {
        latitude: latitude,
        longitude: longitude,
        radius_in_km: radius_in_km
      }
    end

    def missing_latitude_parameters(longitude: 2.3522, radius_in_km: 10)
      {
        longitude: longitude,
        radius_in_km: radius_in_km
      }
    end

    def positive_result
      json_result = [{"rome"=>"F1701", "siret"=>"48802277300037", "distance_m"=>102.04175784, "name"=>"ABEC CONSTRUCTIONS ALPHA", "website"=>"", "additionalInformation"=>"", "fitForDisabledWorkers"=>false, "romeLabel"=>"Construction en béton", "appellations"=>[{"appellationCode"=>"13522", "appellationLabel"=>"Constructeur / Constructrice en maçonnerie et béton armé", "score"=>10}], "naf"=>"4120A", "nafLabel"=>"Construction de bâtiments résidentiels et non résidentiels", "address"=>{"streetNumberAndAddress"=>"", "postcode"=>"31000", "city"=>"Toulouse", "departmentCode"=>"31"}, "position"=>{"lon"=>1.43338, "lat"=>43.601516}, "locationId"=>"13052372-e3c3-47a6-bb76-5e8c806f9c29", "contactMode"=>"EMAIL", "numberOfEmployeeRange"=>"", "voluntaryToImmersion"=>true}, {"rome"=>"F1703", "siret"=>"48802277300037", "distance_m"=>102.04175784, "name"=>"ABEC CONSTRUCTIONS ALPHA", "website"=>"", "additionalInformation"=>"", "fitForDisabledWorkers"=>false, "romeLabel"=>"Maçonnerie", "appellations"=>[{"appellationCode"=>"17441", "appellationLabel"=>"Ouvrier / Ouvrière de la maçonnerie", "score"=>10}], "naf"=>"4120A", "nafLabel"=>"Construction de bâtiments résidentiels et non résidentiels", "address"=>{"streetNumberAndAddress"=>"", "postcode"=>"31000", "city"=>"Toulouse", "departmentCode"=>"31"}, "position"=>{"lon"=>1.43338, "lat"=>43.601516}, "locationId"=>"13052372-e3c3-47a6-bb76-5e8c806f9c29", "contactMode"=>"EMAIL", "numberOfEmployeeRange"=>"", "voluntaryToImmersion"=>true}, {"rome"=>"G1202", "siret"=>"49817620500033", "distance_m"=>111.32171986, "name"=>"DOUBLE BOUCLE", "website"=>"www.doubleboucle.com", "additionalInformation"=>"Notre principale activité est l'animation et la transmission de savoir-faire autour du textile, sous forme de cours de couture, d'ateliers thématiques, de stages et autres événements ponctuels.\n\nAujourd'hui nous sommes à la recherche d'un·e nouveau·elle collaborateur·rice pour agrandir notre équipe pédagogique actuelle.", "romeLabel"=>"Animation d'activités culturelles ou ludiques", "appellations"=>[{"appellationCode"=>"10987", "appellationLabel"=>"Animateur / Animatrice d'atelier d'activités manuelles", "score"=>10}], "naf"=>"8559B", "nafLabel"=>"Enseignements divers", "address"=>{"streetNumberAndAddress"=>"6 Place Lange", "postcode"=>"31300", "city"=>"Toulouse", "departmentCode"=>"31"}, "position"=>{"lon"=>1.4341625, "lat"=>43.6008533}, "locationId"=>"172bb1a0-b925-4d26-94a8-72b5b166f5ec", "contactMode"=>"EMAIL", "numberOfEmployeeRange"=>"1-2", "voluntaryToImmersion"=>true}, {"rome"=>"G1602", "siret"=>"43453957300015", "distance_m"=>202.64883744, "name"=>"L EXTRAPADE", "website"=>"", "additionalInformation"=>"", "fitForDisabledWorkers"=>false, "romeLabel"=>"Personnel de cuisine", "appellations"=>[{"appellationCode"=>"13861", "appellationLabel"=>"Cuisinier / Cuisinière", "score"=>10}], "naf"=>"5610A", "nafLabel"=>"Restaurants et services de restauration mobile", "address"=>{"streetNumberAndAddress"=>"6 PL DE L ESTRAPADE", "postcode"=>"31300", "city"=>"TOULOUSE", "departmentCode"=>"31"}, "position"=>{"lon"=>1.432916, "lat"=>43.598878}, "locationId"=>"464a3b24-4204-4ef6-bb8c-7edb36e0f0f9", "contactMode"=>"EMAIL", "numberOfEmployeeRange"=>"6-9", "voluntaryToImmersion"=>true}].to_json
      { status: 200, body: json_result, headers: {} }
    end

    def wrong_appellation_codes_result
      { status: 400, body: [], headers: {} }
    end



    test 'perform when connexion is ok and params are ok' do
      base_url = "https://staging.immersion-facile.beta.gouv.fr/api/v2/search?distanceKm=" \
                 "#{parameters[:radius_in_km]}&latitude=#{parameters[:latitude]}" \
                 "&longitude=#{parameters[:longitude]}&sortedBy=distance"
      stub_request(:get, base_url).with(headers: headers).to_return(positive_result)
      res = Services::ImmersionFacile.new(**parameters).perform
      assert_equal 4, res.count
      assert_equal "F1701", res.first['rome']
    end

    test 'perform when connexion is ok and params are not ok with wrong appellationcode' do
      stub_url = "https://staging.immersion-facile.beta.gouv.fr/api/v2/search?distanceKm=" \
                 "#{parameters[:radius_in_km]}&latitude=#{parameters[:latitude]}" \
                 "&longitude=#{parameters[:longitude]}&sortedBy=distance"
      stub_request(:get, stub_url).with(headers: headers).to_return(wrong_appellation_codes_result)
      extended_parameters = parameters.merge(appellation_codes: 'wrong')
      res = Services::ImmersionFacile.new(**extended_parameters).perform
      assert_equal 0, res.count
      assert_equal [], res
    end

    test 'perform when connexion is not ok' do
      stub_url = "https://staging.immersion-facile.beta.gouv.fr/api/v2/search?distanceKm=" \
                 "appellationCodes[]='132456'&#{parameters[:radius_in_km]}&latitude=#{parameters[:latitude]}" \
                 "&longitude=#{parameters[:longitude]}&sortedBy=distance"
      Net::HTTP.stub_any_instance(:request, nil) do
        stub_request(:get, stub_url).with(headers: headers).to_return(wrong_appellation_codes_result)
        extended_parameters = parameters.merge(appellation_codes: ['132456'])
        res = Services::ImmersionFacile.new(**extended_parameters).perform
        assert_equal 0, res.count
        assert_equal [], res
      end
    end
  end
end