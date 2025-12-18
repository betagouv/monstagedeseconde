require "application_system_test_case"

module Dashboard::MultiStepper
  class MultiActivitiesTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test "can create multi activity" do
      employer = create(:employer)
      sign_in(employer)

      visit new_dashboard_multi_stepper_multi_activity_path

      fill_in "Indiquez le ou les métiers qui seront observables par l'élève *", with: "Découverte des métiers du numérique"
      fill_in "Décrivez les activités qui seront proposées à l'élève ainsi que le planning prévu en nommant les entreprises accueillantes. *", with: "Observation de différents métiers du numérique chez Google, Facebook et Amazon."

      click_on "Suivant"

      assert_text "Les informations liées au coordinateur"
    end

    test "cannot create multi activity with invalid data" do
      employer = create(:employer)
      sign_in(employer)

      visit new_dashboard_multi_stepper_multi_activity_path

      click_on "Suivant"

      # HTML5 validation prevents submission, so we stay on the page
      assert_text "Le ou les métiers que vous proposez d'observer"
      assert_no_text "Les informations liées au coordinateur"
    end

    # check user can not submit form with empty title
    test "cannot create multi activity with empty title" do
      employer = create(:employer)
      sign_in(employer)

      visit new_dashboard_multi_stepper_multi_activity_path

      fill_in "Décrivez les activités qui seront proposées à l'élève ainsi que le planning prévu en nommant les entreprises accueillantes. *", with: "Description valide"
      # Title is left empty

      click_on "Suivant"

      # Should stay on the same page
      assert_text "Le ou les métiers que vous proposez d'observer"
      assert_no_text "Les informations liées au coordinateur"
    end

    # check user can not submit form with empty description
    test "cannot create multi activity with empty description" do
      employer = create(:employer)
      sign_in(employer)

      visit new_dashboard_multi_stepper_multi_activity_path

      fill_in "Indiquez le ou les métiers qui seront observables par l'élève *", with: "Titre valide"
      # Description is left empty

      click_on "Suivant"

      # Should stay on the same page
      assert_text "Le ou les métiers que vous proposez d'observer"
      assert_no_text "Les informations liées au coordinateur"
    end

    # check user can not submit form with title too long
    test "cannot create multi activity with title too long" do
      employer = create(:employer)
      sign_in(employer)

      visit new_dashboard_multi_stepper_multi_activity_path

      long_title = "a" * (MultiActivity::TITLE_MAX_LENGTH + 10)
      
      fill_in "Indiquez le ou les métiers qui seront observables par l'élève *", with: long_title
      
      # The input has a maxlength attribute, so the value should be truncated
      field = find_field("Indiquez le ou les métiers qui seront observables par l'élève *")
      assert_equal MultiActivity::TITLE_MAX_LENGTH, field.value.length
    end
  end
end
