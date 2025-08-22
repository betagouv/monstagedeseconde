module Dashboard
  module Schools
    class InvitationsController < ApplicationController
      before_action :invitation_params, only: :create
      before_action :set_invitation, only: %i[destroy resend_invitation]

      def index
        authorize! :list_invitations, Invitation
        @invitations = current_user.invitations
      end

      def new
        authorize! :create_invitation, Invitation
        @school      = current_user.school
        @invitation  = current_user.invitations.build
      end

      def create
        authorize! :create_invitation, Invitation
        if text_alert.present?
          redirect_to(
            dashboard_school_users_path(school_id: fetch_school_id),
            alert: "La personne que vous voulez inviter est déjà #{text_alert}"
          ) and return
        end

        @invitation = make_invitation
        if @invitation.save! && invite_staff(invitation: @invitation, from: current_user)
          success_message = "un message d'invitation à " \
                            "#{@invitation.first_name} #{@invitation.last_name} " \
                            "vient d'être envoyé"
          redirect_to dashboard_school_users_path(school_id: fetch_school_id),
                      notice: success_message
        else
          render :new, status: :bad_request
        end
      end

      def destroy
        authorize! :destroy_invitation, Invitation
        if @invitation.destroy
          redirect_to dashboard_school_users_path(school_id: fetch_school_id),
                      notice: 'L\'invitation a bien été supprimée'
        else
          alert_message = "Votre invitation n'a pas pu être supprimée ..."
          redirect_to dashboard_school_users_path(school_id: fetch_school_id),
                      alert: alert_message
        end
      end

      def resend_invitation
        authorize! :create_invitation, Invitation
        invite_staff(invitation: @invitation, from: @invitation.author)
        redirect_to dashboard_school_users_path,
                    notice: 'Votre invitation a été renvoyée'
      end

      def invite_staff(invitation:, from:)
        params = { from: from, invitation: invitation }
        InvitationMailer.staff_invitation(**params).deliver_later
      end

      private

      def make_invitation
        @current_user_uai = current_user.school_code_uai

        @invitation = current_user.invitations
                                  .build(invitation_params.merge(sent_at: Time.now))
        @invitation
      end

      def text_alert
        text_alert = ''
        text_alert = 'inscrite' if already_in_staff?(params, current_user)
        text_alert = 'invitée' if already_invited?(params)
        text_alert
      end

      def already_in_staff?(params, manager)
        staff = ::Users::SchoolManagement.find_by_email(invitation_params[:email])

        staff&.school == manager.school
      end

      def already_invited?(params)
        Invitation.exists?(email: invitation_params[:email])
      end

      def invitation_params
        params.require(:invitation)
              .permit(:first_name,
                      :last_name,
                      :email,
                      :role)
      end

      def fetch_school_id
        current_user.school&.id
      end

      def set_invitation
        @invitation = Invitation.find params[:id]
      end
    end
  end
end
