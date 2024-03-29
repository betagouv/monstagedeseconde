# frozen_string_literal: true

require 'application_system_test_case'

class ManageOrganisationsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include OrganisationFormFiller

  test 'can create Organisation' do
    2.times { create(:school) }
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    assert_difference 'Organisation.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit employer.custom_dashboard_path
        find('#test-create-offer').click
        fill_in_organisation_form(is_public: true, group: group)
        find('span', text: 'Étape 1 sur 5')
        click_on "Suivant"
      end
    end
  end

  test 'create organisation fails gracefuly' do
    sector = create(:sector)
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    travel_to(Date.new(2019, 3, 1)) do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      fill_in_organisation_form(is_public: true, group: group)
      as = 'a' * (InternshipOffer::EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT + 2)
      find('#organisation_employer_description_rich_text', visible: false).set(as)
      find('.fr-alert.fr-alert--error')
    end
  end
end
