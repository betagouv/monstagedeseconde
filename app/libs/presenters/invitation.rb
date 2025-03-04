module Presenters
  class Invitation
    def full_name
      "#{first_name.capitalize} #{last_name.capitalize}"
    end

    def school_name
      author&.school&.name
    end

    def status
      user = ::Users::SchoolManagement.find_by(email:)
      return { type: 'success', label: 'inscrit', status: :subscribed } if user.present?
      return { type: 'warning', label: 'Invitation envoyée', status: :email_sent } if sent_at.present?

      nil
    end

    def role_name
      translator = I18n.t('activerecord.attributes.invitation.roles')
      translator[role.to_sym]
    end

    attr_reader :email, :role, :first_name, :last_name, :author, :sent_at

    private

    def initialize(invitation)
      @invitation     = invitation
      @email          = @invitation.email
      @role           = @invitation.role
      @first_name     = @invitation.first_name
      @last_name      = @invitation.last_name
      @sent_at        = @invitation.sent_at
      @author = @invitation&.author
    end
  end
end
