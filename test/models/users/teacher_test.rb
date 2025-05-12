# frozen_string_literal: true

require 'test_helper'
module Users
  class TeacherTest < ActiveSupport::TestCase
    setup do
      @url_helpers = Rails.application.routes.url_helpers
    end

    test 'creation succeed' do
      school = build(:school, :with_school_manager)
      teacher = Users::SchoolManagement.new(
        role: :teacher,
        email: "jeanne@#{school.email_domain_name}",
        password: 'tototo1Max!!',
        first_name: 'Jeanne',
        last_name: 'Proffe',
        school: school,
        accept_terms: true
      )
      teacher.valid?

      assert teacher.valid?
    end
  end
end
