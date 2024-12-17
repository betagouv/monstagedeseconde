require 'test_helper'

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  headers = {
    'Accept' => 'application/json',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Content-Type' => 'application/json',
    'Host' => 'staging.immersion-facile.beta.gouv.fr',
    'User-Agent' => 'Ruby'
  }

  test 'GET show not logged redirects to sign in' do
    company_params = {
      id: 1234,
      siret: 12_345_678_901_234,
      appellation_code: 1234,
      first_name: 'John',
      last_name: 'Doe',
      email: 'jdoe@gmail.com',
      phone: '0123456789',
      message: 'message'
    }
    get company_path(company_params)
    # success
    assert :success
  end

  test 'POST contact send contac to Immersion Facilitée' do
    company_params = {
      id: 1234,
      location_id: 1234,
      siret: 12_345_678_901_234,
      appellation_code: 5678,
      first_name: 'John',
      last_name: 'Doe',
      email: 'jdoe@gmail.com',
      phone: '0123456789',
      message: 'message'
    }
    body = {
      potentialBeneficiaryFirstName: 'John',
      potentialBeneficiaryLastName: 'Doe',
      potentialBeneficiaryEmail: 'jdoe@gmail.com',
      appellationCode: '5678',
      siret: '12345678901234',
      contactMode: 'EMAIL',
      message: 'message',
      potentialBeneficiaryPhone: '0123456789',
      immersionObjective: 'Découvrir un métier ou un secteur d\'activité',
      locationId: '1234'
    }
    stub_request(:post, 'https://staging.immersion-facile.beta.gouv.fr/api/v2/contact-establishment')
      .with(
        body: body.to_json,
        headers: headers
      ).to_return(status: 201, body: '', headers: {})

    post contact_company_path(company_params)
    # success
    assert_redirected_to recherche_entreprises_path
    assert_equal 'Votre message a bien été envoyé', flash[:notice]
  end

  test 'POST contact send contac to Immersion Facilitée but return 400 error' do
    company_params = {
      id: 1234,
      location_id: 1234,
      siret: 12_345_678_901_234,
      appellation_code: 5678,
      first_name: 'John',
      last_name: 'Doe',
      email: '',
      phone: '0123456789',
      message: 'message'
    }
    body = {
      potentialBeneficiaryFirstName: 'John',
      potentialBeneficiaryLastName: 'Doe',
      potentialBeneficiaryEmail: '',
      appellationCode: '5678',
      siret: '12345678901234',
      contactMode: 'EMAIL',
      message: 'message',
      potentialBeneficiaryPhone: '0123456789',
      immersionObjective: 'Découvrir un métier ou un secteur d\'activité',
      locationId: '1234'
    }
    stub_request(:post, 'https://staging.immersion-facile.beta.gouv.fr/api/v2/contact-establishment')
      .with(
        body: body.to_json,
        headers: headers
      )
      .to_return(status: 400, body: '', headers: {})

    post contact_company_path(company_params)
    # bad request
    assert_redirected_to recherche_entreprises_path
    assert_equal "Une erreur est survenue lors de l'envoi de votre message", flash[:alert]
  end

  def std_company
    { 'locationId' => '123',
      'name' => 'Company',
      'siret' => '12345678901234',
      'contactMode' => 'EMAIL',
      'name' => 'Company 1' }
  end

  def std_company_2
    { 'locationId' => '124',
      'name' => 'Company',
      'siret' => '12345678901236',
      'contactMode' => 'EMAIL',
      'name' => 'Company 2' }
  end

  def std_company_3
    { 'locationId' => '124',
      'name' => 'Company',
      'siret' => '12345678901237',
      'contactMode' => 'EMAIL',
      'name' => 'Company 2' }
  end

  def missing_location_id_company
    { 'locationId' => nil,
      'siret' => '12345678901235',
      'contactMode' => 'EMAIL',
      'name' => 'Company_with_missing_location_id' }
  end

  def other_parameters
    {
      'appellations' => [{ 'appellation_label' => 'appellation_label' }],
      'appellationCode' => 'appellationCode',
      'romeLabel' => 'romeLabel',
      'numberOfEmployeeRange' => 'numberOfEmployeeRange',
      'address' => {
        'streetNumberAndAddress' => 'streetNumberAndAddress',
        'postcode' => 'postcode',
        'city' => 'city'
      }
    }
  end

  test 'get index filters those companies without locationId' do
    companies = [std_company, missing_location_id_company]
    with_and_whitout_location_id = companies.map { |company| company.merge(other_parameters) }
    Services::ImmersionFacile.stub_any_instance(:perform, with_and_whitout_location_id) do
      get companies_path(latitude: 48.8566, longitude: 2.3522, radius_in_km: 10)
      assert_select 'h4.fr-card__title.fr-my-1w.fr-mt-2w',
                    text: std_company['name'],
                    count: 1
      assert_select 'h4.fr-card__title.fr-my-1w.fr-mt-2w',
                    text: missing_location_id_company['name'],
                    count: 0
    end
  end

  test 'get index filters those companies without with offers' do
    create(:weekly_internship_offer_2nde, siret: std_company_2['siret'])
    create(:weekly_internship_offer_2nde, siret: std_company_3['siret'])
    companies = [std_company, std_company_2, std_company_3]
    companies = companies.map { |company| company.merge(other_parameters) }
    Services::ImmersionFacile.stub_any_instance(:perform, companies) do
      get companies_path(latitude: 48.8566, longitude: 2.3522, radius_in_km: 10)
      assert_select 'h4.fr-card__title.fr-my-1w.fr-mt-2w',
                    text: std_company['name'],
                    count: 1
      assert_select 'h4.fr-card__title.fr-my-1w.fr-mt-2w',
                    text: std_company_2['name'],
                    count: 0
      assert_select 'h4.fr-card__title.fr-my-1w.fr-mt-2w',
                    text: std_company_3['name'],
                    count: 0
    end
  end
end
