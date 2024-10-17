# frozen_string_literal: true

module Dashboard
  module Schools::ClassRooms
    class StudentsController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_students, current_user.school

        @class_room = @school.class_rooms.find(params.require(:class_room_id))
        @students = @class_room.students.kept
                               .includes(%i[school internship_applications])
                               .order(:last_name, :first_name)
      end

      def new
        authorize! :manage_school_students, current_user.school

        @class_room = @school.class_rooms.find(params.require(:class_room_id))
        @student = ::Users::Student.new
        @students = @class_room.students.kept
                               .order(:created_at)
      end

      def create
        authorize! :manage_school_students, current_user.school
        @class_room = @school.class_rooms.find(params.require(:class_room_id))
        @student = ::Users::Student.new(formatted_student_params)
        if @student.save
          notify_student
          redirect_to new_dashboard_school_class_room_student_path(@class_room.school, @class_room),
                      notice: 'Elève créé !'
        else
          Rails.logger.info @student.errors.full_messages
          redirect_to new_dashboard_school_class_room_student_path(@class_room.school, @class_room),
                      flash: { danger: 'Erreur : Elève non créé.' }
        end
      end

      private

      def student_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :email,
          :phone,
          :birth_date,
          :gender,
          :class_room_id,
          :school_id,
          :grade
        )
      end

      def formatted_student_params
        student_params.merge(
          school_id: @class_room.school_id,
          grade: @class_room.grade.name,
          class_room_id: @class_room.id,
          password: make_password,
          created_by_teacher: true
        )
      end

      def notify_student
        token = @student.create_reset_password_token
        if @student.email.present?
          StudentMailer.account_created_by_teacher(teacher: current_user, student: @student, token:).deliver_later
        else
          SendSmsJob.perform_later(
            user: @student,
            message: "Votre professeur a créé votre compte, enregistrez votre mot de passe sur : #{edit_user_password_url(
              reset_password_token: token, teacher_id: current_user.id
            )}"
          )

        end
      end

      def make_password
        numbers = (0..9).to_a.sample(3)
        capitals = ('A'..'Z').to_a.sample(3)
        letters = ('a'..'z').to_a.sample(8)
        specials = ['!', '&', '+', '_', 'ç'].sample(2)
        (numbers + capitals + letters + specials).shuffle.join
      end
    end
  end
end
