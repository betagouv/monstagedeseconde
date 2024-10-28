require 'application_system_test_case'

class AreaNotificationTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  # include TeamAndAreasHelper

  test 'workflow for making a team is ok' do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    create :team_member_invitation,
           inviter_id: employer_1.id,
           invitation_email: employer_2.email
    sign_in(employer_2)
    visit employer_2.after_sign_in_path
    click_button 'Oui'

    # visit internship_offer_areas_path
    visit dashboard_internship_offer_areas_path

    # Check Mon Equipe session informations
    assert_equal 2, all('span.fr-badge.fr-badge--no-icon.fr-badge--success', text: 'INSCRIT').count
    assert_equal 2, employer_1.team.team_size
    assert_equal 2, employer_2.team.team_size

    # Check AreaNotification toggling
    last_area_notification = AreaNotification.where(user_id: employer_2.id).last
    assert_equal true, last_area_notification.notify
    find("turbo-frame#area_notification_#{AreaNotification.last.id}").click
    sleep 1
    assert_equal false, last_area_notification.reload.notify
  end
end
