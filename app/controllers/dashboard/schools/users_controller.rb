# frozen_string_literal: true

module Dashboard
  module Schools
    class UsersController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_users, @school
        roles = Invitation.roles
                          .keys
                          .map(&:pluralize)
                          .map(&:to_sym)
        @school_employee_collection = roles.inject([]) do |whole, role|
          whole + @school.send(role).kept
        end
        @school_employee_collection += [@school.school_manager] unless @school.school_manager.try(:discarded?)
        @school_employee_collection.compact!

        school_employees = current_user.school.users

        @invitations = Invitation.for_people_with_no_account_in(school_id: @school.id)
                                 .invited_by(user_id: school_employees.pluck(:id))
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

      def update
        user = @school.users.find(params[:id])

        authorize! :update, user
        user.update!(user_params)
        redirect_back fallback_location: root_path
      rescue ActiveRecord::RecordInvalid
        redirect_back fallback_location: root_path, status: :bad_request
      end

      def claim_school_management
        authorize! :claim_school_management, @school
        target_user = User.find_by(id: params[:id], discarded_at: nil)
        if target_user.nil?
          redirect_to dashboard_school_users_path(@school),
                      flash: { error: "L'utilisateur ciblé n'existe pas." }
          return
        end
        manage_school_managers(target_user)
        redirect_to dashboard_school_users_path(@school),
                    flash: { success: "Vous avez êtes le chef de l'établissement #{target_user.school.name}. C'est votre nom qui figure sur les conventions de stage" }
      rescue StandardError => e
        redirect_to dashboard_school_users_path(@school),
                    flash: { error: "Une erreur est survenue: #{e.message}" }
      end

      private

      def user_params
        params.require(:user)
      end

      def manage_school_managers(target_user)
        other_school_managers = @school.school_managers.where.not(id: target_user.id)
        other_school_managers.each do |school_manager|
          school_manager.update!(role: 'admin_officer')
        end
        target_user.update!(role: 'school_manager') unless target_user.school_manager?
      end
    end
  end
end
