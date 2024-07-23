# frozen_string_literal: true

require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  test 'Agreements association' do
    school = create(:school, :with_school_manager)
    student = create(:student_with_class_room_3e, school:)
    internship_application = create(:weekly_internship_application, user_id: student.id)
    create(:internship_agreement, :created_by_system, internship_application:)
  end
end
