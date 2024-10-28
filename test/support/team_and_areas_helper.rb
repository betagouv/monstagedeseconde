module TeamAndAreasHelper
  def create_team(employer_1, employer_2)
    create(:team_member_invitation,
           :accepted_invitation,
           inviter_id: employer_1.id,
           member_id: employer_2.id)
    create(:team_member_invitation,
           :accepted_invitation,
           inviter_id: employer_1.id,
           member_id: employer_1.id)
    InternshipOfferArea.all.each do |area|
      [employer_1, employer_2].each do |employer|
        AreaNotification.find_or_create_by(user_id: employer.id, internship_offer_area_id: area.id, notify: true)
      end
    end
  end

  def create_internship_offer_visible_by_two(employer_1, employer_2)
    create_team(employer_1, employer_2) if employer_1.team.not_exists? || !employer_1.team.id_in_team?(employer_2.id)
    employer_2.current_area = employer_1.current_area
    employer_2.save
    employers = [employer_1, employer_2]
    InternshipOfferArea.where(employer_id: employers.map(&:id)).each do |area|
      employers.each do |employer|
        AreaNotification.find_or_create_by(
          user_id: employer.id,
          internship_offer_area_id: area.id,
          notify: true
        )
      end
    end

    create(:weekly_internship_offer_2nde,
           internship_offer_area_id: employer_1.current_area.id,
           employer: employer_1)
  end

  def create_employer_and_offer
    employer = create(:employer)
    offer = create(:weekly_internship_offer_2nde,
                   employer: employer,
                   internship_offer_area_id: employer.current_area_id)
    [employer, offer]
  end

  def create_user_operator_and_api_offer(operator_id)
    user_operator = create(:user_operator, operator_id: operator_id)
    offer = create(:api_internship_offer,
                   employer: user_operator,
                   internship_offer_area: user_operator.current_area)
    [user_operator, offer]
  end
end
