# frozen_string_literal: true

module Dashboard
  module Schools
    class UsersController < Dashboard::BaseController
      include NestedSchool

      def index
        authorize! :manage_school_users, @school

        @school_employees = current_user.school.school_managements

        @invitations = Invitation.for_people_with_no_account_in(school_id: @school.id)
                                 .invited_by(user_id: @school_employees.pluck(:id))
                                 .order(created_at: :desc)
      end

      def destroy
        user = @school.users.find(params[:id])
        authorize! :delete, user
        user.update!(school_id: nil, class_room_id: nil)

        redirect_to dashboard_school_users_path(@school),
                    flash: { success: "Le #{user.presenter.role_name} #{user.presenter.short_name} a bien été retiré de votre établissement" }
      rescue ActiveRecord::RecordInvalid
        redirect_to dashboard_school_users_path(@school),
                    flash: { success: "Une erreur est survenue, impossible de supprimer #{user.presenter.human_role} #{user.presenter.short_name} de votre établissement: #{e.record.full_messages}" }
      end
    end
  end
end
