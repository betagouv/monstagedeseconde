# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOccupationsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include InternshipOccupationFormFiller
  # ------------------------
  # create internship_occupation
  # ------------------------

  test 'can create InternshipOccupation' do
    employer = create(:employer)
    # group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    assert_difference 'InternshipOccupation.count' do
      travel_to(Date.new(2024, 3, 1)) do
        visit employer.custom_dashboard_path
        find('#test-create-offer').click
        fill_in_internship_occupation_form
        find('li#downshift-0-item-0', wait: 8).click
        find('span', text: 'Étape 1 sur 3')
        click_on 'Suivant'
      end
    end
    assert_equal 'Étape 2 sur 3', find('h2 > span.fr-stepper__state').text
    assert InternshipOccupation.last.coordinates.present?
  end
  # test 'can not create public InternshipOccupation without group' do
  #   2.times { create(:school) }
  #   employer = create(:employer)
  #   group = create(:group, name: 'hello', is_public: true)
  #   sign_in(employer)
  #   assert_no_difference 'InternshipOccupation.count' do
  #     travel_to(Date.new(2024, 3, 1)) do
  #       visit employer.custom_dashboard_path
  #       find('#test-create-offer').click
  #       fill_in_internship_occupation_form(is_public: true, group:)
  #       find('label', text: 'Publique').click
  #       find('span', text: 'Étape 1 sur 5')
  #       click_on 'Suivant'
  #     end
  #   end
  # end

  test 'create internship_occupation fails gracefully' do
    employer = create(:employer)
    sign_in(employer)
    travel_to(Date.new(2024, 3, 1)) do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      fill_in_internship_occupation_form(full_address: 'fdfqq5fdsfqdsfdssfqsdf')
      assert_raises(Capybara::ElementNotFound) { find('li#downshift-0-item-0') }
    end
  end

  # ------------------------
  # update internship_occupation
  # ------------------------

  test 'update internship_occupation is ok once internship_occupation is retrieved' do
    travel_to(Date.new(2024, 3, 1)) do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sign_in(employer)
      visit edit_dashboard_stepper_internship_occupation_path(internship_occupation)
      as = 'a' * 10
      fill_in_internship_occupation_form(description: as, full_address: ' ')
      find('button[name="button"][type="submit"]').click
      assert_equal 'Étape 2 sur 3', find('h2 > span.fr-stepper__state').text
    end
  end

  test 'update internship_occupation fails gracefuly when employer description is too long' do
    skip 'this test is relevant and shall be reactivated by november 2024'
    employer = create(:employer)
    internship_occupation = create(:internship_occupation, employer:)
    sign_in(employer)
    travel_to(Date.new(2024, 3, 1)) do
      visit edit_dashboard_stepper_internship_occupation_path(internship_occupation)
      as = 'a' * (InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT + 2)
      fill_in_internship_occupation_form(description: as, full_address: '')
      assert_equal 'La description est trop longue', find('.fr-alert.fr-alert--error').text
      find('button[name="button"][type="submit"][disabled]')
    end
  end
end
