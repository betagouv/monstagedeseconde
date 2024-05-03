class InternshipOfferArea < ApplicationRecord
  belongs_to :employer,
             polymorphic: true

  has_many :users,
           foreign_key: 'current_area_id',
           class_name: 'User',
           inverse_of: :internship_offer_area
  has_many :internship_offers
  has_many :area_notifications, dependent: :destroy

  validates :employer_id, :name, presence: true

  validate :name_uniqueness_in_team

  def team_sibling_areas
    return InternshipOfferArea.none if employer.team.not_exists?

    employer.internship_offer_areas.where.not(id: id)
  end

  def single_human_in_charge?
    return true if employer.team.not_exists?

    AreaNotification.where(user_id: employer.team_members_ids)
                    .where(notify: true)
                    .where(internship_offer_area_id: id)
                    .to_a
                    .count <= 1
  end

  def people_in_charge
    return [] if employer.team.not_exists?

    User.where(id: AreaNotification.where(user_id: employer.team_members_ids)
                                   .where(notify: true)
                                   .where(internship_offer_area_id: id))
  end

  def destroy
    return if collegues_offers_in_area.any?

    target_area = team_sibling_area_sample
    return if target_area.nil?
    if employer.internship_offers.any?
      move_remaining_offers_to(target_area: target_area)
    end
    move_user_references_to_area(target_area_id: target_area.id)
    super
  end

  def move_remaining_offers_to(target_area:)
    InternshipOffer.where(internship_offer_area_id: id).each do |offer|
      # offer shall keep a valid reference to internship_offer_area_id
      offer.internship_offer_area = target_area
      offer.anonymize
    end
  end

  def team_sibling_area_sample
    employer.internship_offer_areas
            .where.not(id: id)
            .sample
  end

  def move_user_references_to_area(target_area_id:)
    user_to_update_list = [employer]
    if employer.team.alive?
      employer.db_team_members.each do |user|
        next unless user.current_area_id == id

        user_to_update_list << user if user.id != employer.id
      end
    end
    user_to_update_list.each { |user| user.current_area_id_memorize(target_area_id) }
  end

  def collegues_offers_in_area
    return InternshipOffer.none if employer.team.not_exists?

    other_employer_ids = employer.team_members_ids - [employer.id]
    InternshipOffer.where(employer_id: other_employer_ids)
                   .where(internship_offer_area_id: id)
  end

  private

  def name_uniqueness_in_team
    employer = User.find_by(id: employer_id)
    if employer.nil?
      errors.add(:employer_id, :invalid)
    elsif employer.internship_offer_areas.pluck(:name).include?(name)
      errors.add(:name, :taken)
    end
  end
end
