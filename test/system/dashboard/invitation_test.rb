require 'application_system_test_case'

module Dashboard
  class InvitationTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'invite a school_management of another school' do
      school = create(:school)
      other_school = create(:school)
      school_manager = create(:school_manager, school: school, email: 'test@ac-paris.fr')
      other_school_admin = create(:admin_officer, school: other_school, email: 'testo@ac-paris.fr')

      sign_in(school_manager)
      visit dashboard_school_users_path(school_id: school.id)
      assert_difference 'Invitation.count' do
        click_link("Inviter un membre de l'équipe")
        fill_in('Nom', with: 'Picasso')
        fill_in('Prénom', with: 'Pablo')
        fill_in('Adresse électronique', with: other_school_admin.email)
        click_button("Inviter un membre de l'équipe")
      end
    end

    test 'resend invite a school_management of another school' do
      school = create(:school)
      school_manager = create(:school_manager, school: school, email: 'test@ac-paris.fr')
      other_school = create(:school)
      other_school_admin_email = 'testo@ac-paris.fr'
      invitation = create(:invitation, user: school_manager, email: other_school_admin_email)

      sign_in(school_manager)
      visit dashboard_school_users_path(school_id: school.id)
      assert_no_difference 'Invitation.count' do
        accept_confirm do
          find("button.fr-icon-mail-line").click
          # assert_text("L'invitation a été renvoyée à #{other_school_admin.email
        end
      end
    end
  end
end
