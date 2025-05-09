class TeamMemberInvitation < ApplicationRecord
  # id bigint NOT NULL,
  # created_at timestamp(6) without time zone NOT NULL,
  # updated_at timestamp(6) without time zone NOT NULL,
  # inviter_id bigint NOT NULL,
  # member_id bigint,
  # invitation_email character varying(150) NOT NULL,
  # invitation_refused_at timestamp(6) without time zone,
  # aasm_state character varying DEFAULT 'pending_invitation'::character varying
  include AASM
  # Relations
  belongs_to :inviter,
             class_name: 'User'
  belongs_to :member,
             class_name: 'User',
             optional: true

  # Validations
  validates :member_id,
            uniqueness: { scope: %i[inviter_id invitation_email],
                          message: 'Vous avez déjà invité ce membre dans votre équipe' },
            on: :create

  validates :invitation_email,
            presence: true,
            format: { with: Devise.email_regexp }

  # Scopes
  scope :with_pending_invitations, -> { where(invitation_refused_at: nil, member_id: nil) }
  scope :refused_invitations, -> { where.not(invitation_refused_at: nil) }

  # AASM
  aasm do
    state :pending_invitation, initial: true
    state :accepted_invitation,
          :refused_invitation

    event :accept_invitation, after: :after_accepted_invitation do
      transitions from: %i[pending_invitation],
                  to: :accepted_invitation
    end
    event :refuse_invitation do
      transitions from: :pending_invitation,
                  to: :refused_invitation,
                  after: proc { |*_args|
                    update(invitation_refused_at: Time.now, member_id: nil)
                  }
    end
  end

  # instance methods

  def not_in_a_team?
    pending_invitation? || refused_invitation?
  end

  def send_invitation
    EmployerMailer.team_member_invitation_email(team_member_invitation: self, user: fetch_invitee_in_db)
                  .deliver_later(wait: 1.second)
  end

  def presenter(current_user)
    @presenter ||= ::Presenters::TeamMemberInvitation.new(team_member_invitation: self, current_user: current_user)
  end

  def fetch_invitee_in_db
    user = User.kept.find_by(email: invitation_email)
    return nil unless user.try(:employer_like?)

    user
  end

  def member_is_inviter?
    member_id == inviter_id
  end
  alias member_is_owner? member_is_inviter?

  def reject_pending_invitations
    team = Team.new(self)
    team_member_ids = team.team_members.map(&:member_id)
    # reject my invitations to my team
    TeamMemberInvitation.pending_invitation
                        .where(inviter_id: member_id)
                        .where(member_id: team_member_ids)
                        .each do |pending_member|
      pending_member.destroy
    end

    # refuse invitations to me
    TeamMemberInvitation.pending_invitation
                        .where.not(inviter_id: team_member_ids)
                        .where(invitation_email: invitation_email)
                        .each do |pending_member|
      pending_member.refuse_invitation!
    end
  end

  def team_owner_id
    return nil if team.alive?

    team.team_owner_id
  end

  def team
    Team.new(self)
  end

  def refused_invitation?
    invitation_refused_at.present?
  end

  def destroy_member_original_offer_area
    member = fetch_invitee_in_db

    destroy_member_offer_area(member) if member.came_from_invitation?
  end

  private

  def after_accepted_invitation
    team.activate_member
  end

  def destroy_member_offer_area(member)
    area = InternshipOfferArea.where(employer_id: member.id).first
    return if area.internship_offers.any?

    if area
      Rails.logger.info "Users avec cette zone: #{User.where(current_area_id: area.id).count}"
      Rails.logger.info "Associations: #{area.class.reflect_on_all_associations.map(&:name)}"

      # Mettre à jour les utilisateurs
      User.where(current_area_id: area.id).update_all(
        current_area_id: inviter.current_area_id
      )

      area.area_notifications.destroy_all

      # Essayer de forcer la suppression avec destroy!
      begin
        area.reload # Recharger pour être sûr d'avoir les dernières données
        unless area.destroy
          Rails.logger.error "Échec normal: #{area.errors.full_messages}"
          # Forcer avec destroy! pour voir l'erreur complète
          area.destroy!
        end
      rescue StandardError => e
        Rails.logger.error "Erreur de suppression: #{e.full_message}"
        # En dernier recours, essayer delete
        area.delete
      end
    end

    member.current_area_id = inviter.current_area_id
    member.save!
  end
end
