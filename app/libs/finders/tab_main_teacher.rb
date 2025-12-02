# frozen_string_literal: true
module Finders
  class TabMainTeacher
    def pending_class_rooms_actions_count
      school.nil? ? 0 : school.students.without_class_room.count
    end

    def pending_agreements_count
      # internship_agreement approved with internship_agreement without terms_accepted
      states_with_actions = %i[completed_by_employer started_by_school_manager validated]
      @pending_internship_agreement_count ||= InternshipApplication
                                                    .through_teacher(teacher: teacher)
                                                    .approved
                                                    .joins(:internship_agreement)
                                                    .where(internship_agreement: { aasm_state: states_with_actions })
                                                    .count
    end


    private
    attr_reader :teacher, :school


    def initialize(teacher:)
      @teacher = teacher
      @school = teacher.try(:school)
    end
  end
end
