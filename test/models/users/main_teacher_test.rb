# frozen_string_literal: true

require 'test_helper'
module Users
  class MainTeacherTest < ActiveSupport::TestCase
    setup do
      @url_helpers = Rails.application.routes.url_helpers
    end

    test 'creation fails teacher requires an .ac ending mail' do
      teacher = Users::SchoolManagement.new(
        role: :main_teacher,
        email: 'teacher@etablissement.com',
        school: create(:school)
      )

      assert teacher.invalid?
      assert_not_empty teacher.errors[:email]
    end

    test 'creation succeed' do
      department = Department.find_by(code: '75')
      school = build(:school, :with_school_manager, department:)
      teacher = Users::SchoolManagement.new(
        role: :main_teacher,
        email: "jeanne@#{school.email_domain_name}",
        password: 'tototo1Max!!',
        first_name: 'Jeanne',
        last_name: 'Proffe',
        school: school,
        accept_terms: true
      )
      validity = teacher.valid?
      puts teacher.email
      puts teacher.errors.full_messages unless validity
      assert teacher.valid?
    end
  end
end
