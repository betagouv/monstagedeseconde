require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def std_company
    { 'locationId' => '123',
      'name' => 'Company',
      "siret" => '12345678901234',
      'name' => 'Company 1' }
  end

  def std_company_2
    { 'locationId' => '124',
      'name' => 'Company',
      'siret' => '12345678901236',
      'name' => 'Company 2' }
  end

  def std_company_3
    { 'locationId' => '124',
      'name' => 'Company',
      'siret' => '12345678901237',
      'name' => 'Company 2' }
  end

  def missing_location_id_company
    { 'locationId' => nil,
      'siret' => '12345678901235',
      'name' => 'Company_with_missing_location_id' }
  end

  def other_parameters
    {
      "appellations" => [{ "appellation_label" => 'appellation_label'}],
      "appellationCode" => 'appellationCode',
      "romeLabel" => 'romeLabel',
      "numberOfEmployeeRange" => 'numberOfEmployeeRange',
      "address" => {
        "streetNumberAndAddress" => 'streetNumberAndAddress',
        "postcode" => 'postcode',
        "city" => 'city'
      }
    }
  end

  test 'get index filters those companies without locationId' do
    companies = [std_company, missing_location_id_company]
    with_and_whitout_location_id  = companies.map { |company| company.merge(other_parameters)}
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
    create(:weekly_internship_offer, siret: std_company_2['siret'])
    create(:weekly_internship_offer, siret: std_company_3['siret'])
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
