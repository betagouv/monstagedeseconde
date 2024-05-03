require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  headers = {
    'Accept'=>'application/json',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Content-Type'=>'application/json',
    'Host'=>'staging.immersion-facile.beta.gouv.fr',
    'User-Agent'=>'Ruby'
  }

  test 'GET show not logged redirects to sign in' do
    company_params = {
      id: 1234,
      siret: 12345678901234,
      appellation_code: 1234,
      first_name: 'John',
      last_name: 'Doe',
      email: 'jdoe@gmail.com',
      phone: '0123456789',
    }
    get company_path(company_params)
    # success
    assert :success
  end

  test 'POST contact send contac to Immersion Facilitée' do
    company_params = {
      id: 1234,
      location_id: 1234,
      siret: 12345678901234,
      appellation_code: 5678,
      first_name: 'John',
      last_name: 'Doe',
      email: 'jdoe@gmail.com',
      phone: '0123456789',
    }
    body = {
      potentialBeneficiaryFirstName: 'John',
      potentialBeneficiaryLastName: 'Doe',
      potentialBeneficiaryEmail: 'jdoe@gmail.com',
      appellationCode: "5678",
      siret: "12345678901234",
      contactMode: 'EMAIL',
      message: 'message',
      potentialBeneficiaryPhone: '0123456789',
      immersionObjective: 'Découvrir un métier ou un secteur d\'activité',
      locationId: '1234'
    }
    stub_request(:post, "https://staging.immersion-facile.beta.gouv.fr/api/v2/contact-establishment").
          with(
            body: body.to_json,
            headers: headers
          ).
          to_return(status: 201, body: "", headers: {}) 

    post contact_company_path(company_params)
    # success
    assert_redirected_to recherche_entreprises_path
    assert_equal 'Votre message a bien été envoyé', flash[:notice]
  end

  test 'POST contact send contac to Immersion Facilitée but return 400 error' do
    company_params = {
      id: 1234,
      location_id: 1234,
      siret: 12345678901234,
      appellation_code: 5678,
      first_name: 'John',
      last_name: 'Doe',
      email: '',
      phone: '0123456789',
    }
    body = {
      potentialBeneficiaryFirstName: 'John',
      potentialBeneficiaryLastName: 'Doe',
      potentialBeneficiaryEmail: '',
      appellationCode: "5678",
      siret: "12345678901234",
      contactMode: 'EMAIL',
      message: 'message',
      potentialBeneficiaryPhone: '0123456789',
      immersionObjective: 'Découvrir un métier ou un secteur d\'activité',
      locationId: '1234'
    }
    stub_request(:post, "https://staging.immersion-facile.beta.gouv.fr/api/v2/contact-establishment").
          with(
            body: body.to_json,
            headers: headers
          ).
          to_return(status: 400, body: "", headers: {}) 

    post contact_company_path(company_params)
    # bad request
    assert_redirected_to recherche_entreprises_path
    assert_equal "Une erreur est survenue lors de l'envoi de votre message", flash[:alert]
  end
end
