# frozen_string_literal: true

module Presenters
  module Dashboard
    class ClassRoomStats
      def total_student
        class_room_students_ids.count
      end

      def total_student_confirmed
        Users::Student.where(id: class_room_students_ids)
                      .confirmed
                      .size
      end

      def total_student_with_zero_application
        zero_application_students_with_status(status: %i[submitted approved])
      end

      def total_student_with_zero_internship
        zero_application_students_with_status(status: %i[approved])
      end

      private

      attr_reader :class_room

      def initialize(class_room:)
        @class_room = class_room
      end

      def zero_application_students_with_status(status:)
        rest_of_class_room_size(
          reject_list: track_student_with_listed_status(listed_status: status)
        )
      end

      def class_room_students_ids
        Rails.cache.fetch("class_room_students_ids_#{class_room.id}") do
          class_room.students.kept.ids
        end
      end

      def track_student_with_listed_status(listed_status: [])
        Users::Student.where(id: class_room_students_ids)
                      .joins(:internship_applications)
                      .where(internship_applications: { aasm_state: listed_status })
      end

      def rest_of_class_room_size(reject_list:)
        class_room_students_ids.count - reject_list.ids.uniq.count
      end
    end
  end
end
