# frozen_string_literal: true

require "application_system_test_case"

module Admin
  class SchoolManagementsTest < ApplicationSystemTestCase
    setup do
      @god = create(:god)
      @school = create(:school, name: "Lycée Jean Moulin", city: "Bordeaux", code_uai: "0330001A")
      @school_management = create(:school_manager,
                                  first_name: "Marie",
                                  last_name:  "Curie",
                                  school:     @school)
      @other_school = create(:school, name: "Lycée Victor Hugo", city: "Paris", code_uai: "0750001Z")
    end

    test "admin can search for school management personnel by name" do
      sign_in @god
      visit admin_school_managements_path

      fill_in "Nom, prénom, email ou code UAI…", with: "Curie"
      assert_text "Curie", wait: 2
      assert_text @school.name
    end

    test "admin can search by code UAI" do
      sign_in @god
      visit admin_school_managements_path

      fill_in "Nom, prénom, email ou code UAI…", with: "0330001A"
      assert_text "Curie", wait: 2
    end

    test "search shows no results message when nothing matches" do
      sign_in @god
      visit admin_school_managements_path

      fill_in "Nom, prénom, email ou code UAI…", with: "zzzmatch999"
      assert_text "Aucun résultat", wait: 2
    end

    test "clicking Gérer navigates to the detail page" do
      sign_in @god
      visit admin_school_managements_path

      fill_in "Nom, prénom, email ou code UAI…", with: "Curie"
      assert_text "Gérer", wait: 2
      click_on "Gérer"

      assert_current_path admin_school_management_path(@school_management)
      assert_text "Établissement principal (immuable)"
      assert_text @school.name
      assert_text "Associer un établissement"
    end

    test "admin can associate an extra school to a personnel" do
      sign_in @god
      visit admin_school_management_path(@school_management)

      fill_in "Nom, commune ou code UAI…", with: "Victor"
      assert_text "Lycée Victor Hugo", wait: 2
      click_on "Associer"

      assert_text "Lycée Victor Hugo", wait: 2
      assert UserSchool.exists?(user: @school_management, school: @other_school)
    end

    test "already associated school does not appear in search results" do
      UserSchool.create!(user: @school_management, school: @other_school)
      sign_in @god
      visit admin_school_management_path(@school_management)

      fill_in "Nom, commune ou code UAI…", with: "Victor"
      assert_text "Aucun résultat", wait: 2
    end

    test "admin can remove an extra school association after confirmation" do
      UserSchool.create!(user: @school_management, school: @other_school)
      sign_in @god
      visit admin_school_management_path(@school_management)

      assert_text "Lycée Victor Hugo"
      remove_school_association(@other_school)

      assert_text "supprimée", wait: 2
      assert_not UserSchool.exists?(user: @school_management, school: @other_school)
      within("#extra-schools") { assert_no_text "Paris — 0750001Z" }
    end

    test "cycle complet : associer, retirer avec confirmation, réassocier, retirer à nouveau" do
      sign_in @god
      visit admin_school_management_path(@school_management)

      # 1. Associer Lycée Victor Hugo
      fill_in "Nom, commune ou code UAI…", with: "Victor"
      assert_text "Lycée Victor Hugo", wait: 2
      click_on "Associer"
      assert_text "Lycée Victor Hugo", wait: 2
      assert UserSchool.exists?(user: @school_management, school: @other_school)

      # 2. Retirer avec confirmation
      remove_school_association(@other_school)
      assert_text "supprimée", wait: 2
      within("#extra-schools") { assert_no_text "Paris — 0750001Z" }
      assert_not UserSchool.exists?(user: @school_management, school: @other_school)

      # 3. Réassocier
      fill_in "Nom, commune ou code UAI…", with: "Victor"
      assert_text "Lycée Victor Hugo", wait: 2
      click_on "Associer"
      assert_text "Lycée Victor Hugo", wait: 2
      assert UserSchool.exists?(user: @school_management, school: @other_school)

      # 4. Retirer à nouveau
      remove_school_association(@other_school)
      assert_text "supprimée", wait: 2
      within("#extra-schools") { assert_no_text "Paris — 0750001Z" }
      assert_not UserSchool.exists?(user: @school_management, school: @other_school)
    end

    private

    def remove_school_association(school)
      user_school = UserSchool.find_by!(user: @school_management, school: school)
      form_selector = "form[action='#{admin_school_management_user_school_path(@school_management, user_school)}']"

      within("#extra-schools") do
        form = find(form_selector, match: :first)
        page.execute_script("arguments[0].requestSubmit()", form.native)
      end
    end
  end
end
