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

      private

      def student_params
        params.expect(user: [
          :first_name,
          :last_name,
          :email,
          :phone,
          :birth_date,
          :gender,
          :class_room_id,
          :school_id,
          :grade
        ])
      end

      def formatted_student_params
        student_params.merge(
          school_id: @class_room.school_id,
          grade: @class_room.grade,
          class_room_id: @class_room.id,
          password: make_password
        )
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
