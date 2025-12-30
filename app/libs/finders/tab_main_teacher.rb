# frozen_string_literal: true
module Finders
  class TabMainTeacher < TabSchoolManager
    def pending_class_rooms_actions_count
      school.nil? ? 0 : school.students.without_class_room.count
    end

    private

    attr_reader :teacher, :school

    def initialize(teacher:)
      @teacher = teacher
      @school = teacher.try(:school)
    end
  end
end
