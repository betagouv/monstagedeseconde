# frozen_string_literal: true
module Finders
  class TabSchoolManager
    def pending_class_rooms_actions_count
      school.students.without_class_room.count
    end

    def pending_agreements_count
      agreements_count(selected_agreements.mono)
    end

    def pending_multi_agreements_count
      agreements_count(selected_agreements.multi)
    end

    private

    attr_reader :school

    def agreements_count(agreements)
      states_with_actions = InternshipAgreement::EXPECTED_ACTION_FROM_SCHOOL_MANAGER_STATES
      count = agreements.where(aasm_state: states_with_actions).count

      agreements_to_be_signed = agreements.where(aasm_state: %i[signatures_started validated])
      count += missing_signatures_count(agreements_to_be_signed, role: "school_manager")
    end

    def missing_signatures_count(agreements_to_be_signed, role:)
      return 0 if agreements_to_be_signed.empty?

      agreements_signed_by_school_manager = agreements_to_be_signed.select do |agreement|
        agreement.signature_signed_by_role?(role)
      end
      agreements_to_be_signed.count - agreements_signed_by_school_manager.count
    end

    def selected_agreements
      InternshipAgreement.kept
                         .joins(internship_application: {student: :school})
                         .where(school: {id: school.id})
    end

    def initialize(school:)
      @school = school
    end
  end
end
