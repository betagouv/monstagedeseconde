# frozen_string_literal: true

require 'test_helper'

module Presenters
  class UserTest < ActiveSupport::TestCase
    delegate :application, to: Rails
    delegate :routes, to: :application
    delegate :url_helpers, to: :routes

    test '.default_internship_offers_path with nil user, works' do
      assert_equal url_helpers.internship_offers_path, Presenters::User.new(nil).default_internship_offers_path
    end

    test '.default_internship_offers_path with employer user returns to all offers' do
      employer = create(:employer)
      assert_equal url_helpers.internship_offers_path, employer.presenter.default_internship_offers_path
    end

    test '.default_internship_offers_path with main_teacher having no school returns to all offers' do
      school_manager = create(:school_manager)
      main_teacher = create(:main_teacher, school: school_manager.school)
      main_teacher.update!(school_id: nil, class_room_id: nil)
      assert_equal url_helpers.internship_offers_path, main_teacher.presenter.default_internship_offers_path
    end

    test '.default_internship_offers_path with main_teacher having a school returns to offers prefiltered for his school' do
      school_manager = create(:school_manager)
      main_teacher = create(:main_teacher, school: school_manager.school)

      assert_equal url_helpers.internship_offers_path(school_manager.default_search_options),
                   main_teacher.presenter.default_internship_offers_path
    end

    test '.default_internship_offers_path includes expected params' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      class_room = create(:class_room,  school: school)
      student = create(:student, school: school, class_room: class_room)
      path = student.presenter.default_internship_offers_path
      params = CGI.parse(URI.parse(path).query)
      assert_equal [school.city], params["city"]
      assert_equal [school.coordinates.lat.to_s], params["latitude"]
      assert_equal [school.coordinates.lon.to_s], params["longitude"]
      assert_equal [Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER.to_s], params["radius"]
    end

    test '#civil_name' do
      student = build(:student, gender: nil)
      assert_equal student.last_name, student.presenter.civil_name
      student = build(:student, gender: 'np')
      assert_equal student.last_name, student.presenter.civil_name
      student = build(:student, gender: 'm')
      assert_equal "Monsieur #{student.last_name}", student.presenter.civil_name
      student = build(:student, gender: 'f')
      assert_equal "Madame #{student.last_name}", student.presenter.civil_name
    end
  end
end
