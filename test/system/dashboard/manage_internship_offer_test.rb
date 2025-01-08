# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOffersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def wait_form_submitted
    find('.alert-sticky')
  end

  # def fill_in_trix_editor(id, with:)
  #   find(:xpath, "//trix-editor[@id='#{id}']").click.set(with)
  # end

  test 'Employer can edit internship offer' do
    travel_to(Date.new(2024, 3, 1)) do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer:)

      sign_in(employer)
      visit edit_dashboard_internship_offer_path(internship_offer)
      find('input[name="internship_offer[employer_chosen_name]"]').fill_in(with: 'NewCompany')

      click_on "Publier l'offre"

      wait_form_submitted
      assert(/NewCompany/.match?(internship_offer.reload.employer_name))
    end
  end

  test 'Employer can edit an unpublished internship offer and have it published' do
    travel_to(Date.new(2025, 3, 1)) do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer:)
      assert internship_offer.grades.include?(Grade.seconde)
      internship_offer.unpublish!
      refute internship_offer.published?

      sign_in(employer)
      visit edit_dashboard_internship_offer_path(internship_offer)
      find('input[name="internship_offer[employer_chosen_name]"]').fill_in(with: 'NewCompany')
      click_on "Publier l'offre"

      wait_form_submitted
      assert internship_offer.reload.published?
      assert(/NewCompany/.match?(internship_offer.employer_name))
    end
  end

  test 'Employer can discard internship_offer' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer_2nde, employer:)

    sign_in(employer)

    visit internship_offer_path(internship_offer)
    assert_changes -> { internship_offer.reload.discarded_at } do
      page.find('.test-discard-button').click
      page.find("button[data-test-delete-id='delete-#{dom_id(internship_offer)}']").click
    end
  end

  test 'Employer can change max candidates parameter back and forth' do
    travel_to(Date.new(2024, 1, 10)) do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_3eme,
                                employer:,
                                internship_offer_area_id: employer.current_area_id)
      assert_equal 1, internship_offer.max_candidates
      sign_in(employer)
      visit dashboard_internship_offers_path(internship_offer:)
      page.find("a[data-test-id=\"#{internship_offer.id}\"]").click

      find('.test-edit-button').click
      find('label[for="internship_type_false"]').click # max_candidates can be set to many now
      execute_script("document.getElementById('internship_offer_max_candidates').removeAttribute('d-none')")

      find('label[for="internship_type_false"]').click # max_candidates can be set to many now
      within('.form-group-select-max-candidates') do
        fill_in('Nombre total d\'élèves que vous souhaitez accueillir sur la période de stage', with: 4)
      end
      fill_in('Nombre maximal d’élèves par groupe', with: 4)
      click_button('Publier l\'offre')
      assert_equal 4,
                   internship_offer.reload.max_candidates,
                   'faulty max_candidates'

      visit dashboard_internship_offers_path(internship_offer:)
      page.find("a[data-test-id=\"#{internship_offer.id}\"]").click
      find('.test-edit-button').click
      find('label[for="internship_type_true"]').click # max_candidates is now set to 1
      click_button('Publier l\'offre')
      assert_equal 1, internship_offer.reload.max_candidates
    end
  end

  test 'Employer can duplicate an internship offer' do
    employer = create(:employer)
    current_internship_offer = create(
      :weekly_internship_offer_2nde,
      employer:,
      internship_offer_area_id: employer.current_area_id
    )
    sign_in(employer)
    visit dashboard_internship_offers_path(internship_offer: current_internship_offer)
    page.find("a[data-test-id=\"#{current_internship_offer.id}\"]").click
    find('.test-duplicate-button').click
    find('h1.h2', text: 'Dupliquer une offre')
    click_button('Dupliquer l\'offre')
    assert_selector(
      '#alert-text',
      text: "L'offre de stage a été dupliquée en tenant " \
            'compte de vos éventuelles modifications.'
    )
  end

  test "Employers in a team can see each other's offers" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    employer_2.current_area.update(name: 'Nantes')
    create(:team_member_invitation,
           :accepted_invitation,
           inviter_id: employer_1.id,
           member_id: employer_2.id)
    create(:team_member_invitation,
           :accepted_invitation,
           inviter_id: employer_1.id,
           member_id: employer_1.id)
    internship_offer_1 = create(:weekly_internship_offer_2nde, employer: employer_1,
                                                               internship_offer_area_id: employer_1.current_area_id)
    internship_offer_2 = create(:weekly_internship_offer_2nde, employer: employer_2,
                                                               internship_offer_area_id: employer_2.current_area_id)
    internship_offer_3 = create(:weekly_internship_offer_2nde, employer: employer_3,
                                                               internship_offer_area_id: employer_3.current_area_id)

    sign_in(employer_1)
    visit dashboard_internship_offers_path
    click_link 'Offres de stage'
    assert page.has_content?(internship_offer_1.title)
    click_link(employer_2.current_area.name)
    click_link 'Offres de stage'
    assert page.has_content?(internship_offer_2.title)
    assert_select('a', text: employer_3.current_area.name, count: 0)
  end

  test 'Employers users shall not be pushed to home when no agreement in list' do
    employer = create(:employer)
    sign_in(employer)
    visit dashboard_internship_offers_path
    click_link('Conventions')
    find('h4.fr-h4', text: 'Aucune convention de stage ne requiert votre attention pour le moment.')
  end

  test 'Operator users shall not be pushed to home when no agreement in list' do
    user_operator = create(:user_operator)
    sign_in(user_operator)
    visit dashboard_internship_offers_path
    assert page.has_css?('a', text: 'Candidatures', count: 1)
    assert page.has_css?('a', text: 'Conventions', count: 0)
  end
end
