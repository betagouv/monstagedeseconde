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
        # select radio button "Publique"
        find('label', text: 'Publique').click
        select 'hello', from: 'organisation_group_id'
        find('span', text: 'Étape 1 sur 5')
        click_on "Suivant"
      end
    end
  end
  test 'can not create public Organisation without group' do
    2.times { create(:school) }
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    assert_no_difference 'Organisation.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit employer.custom_dashboard_path
        find('#test-create-offer').click
        fill_in_organisation_form(is_public: true, group: group)
        find('label', text: 'Publique').click
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
      fill_in 'Description de l’entreprise', with: as
      find('.fr-alert.fr-alert--error')
    end
  end
end
