# frozen_string_literal: true

require "test_helper"

module Acl
  class ReportingTest < ActiveSupport::TestCase
    test "prefecture statistician allowed only for own department" do
      statistician = create(:statistician) # department '60'
      own = statistician.department_name

      assert Acl::Reporting.new(user: statistician, params: { department: own }).allowed?
      refute Acl::Reporting.new(user: statistician, params: { department: "Ain" }).allowed?
      refute Acl::Reporting.new(user: statistician, params: {}).allowed?
    end

    test "academy statistician allowed only within his academy departments" do
      academy = create(:academy)
      dept_in = Department.create!(academy:, name: "Paris", code: "75")
      out_academy = create(:academy, name: "Académie de Lyon", email_domain: "ac-lyon.fr")
      dept_out = Department.create!(academy: out_academy, name: "Rhône", code: "69")
      statistician = create(:academy_statistician, academy:)

      assert Acl::Reporting.new(user: statistician, params: { department: [ dept_in.name ] }).allowed?
      assert Acl::Reporting.new(user: statistician, params: { department: dept_in.name }).allowed?
      refute Acl::Reporting.new(user: statistician, params: { department: [ dept_out.name ] }).allowed?
      refute Acl::Reporting.new(user: statistician,
                                params: { department: [ dept_in.name, dept_out.name ] }).allowed?
      refute Acl::Reporting.new(user: statistician, params: {}).allowed?
    end

    test "academy region statistician allowed only within his region departments" do
      region = create(:academy_region, name: "Île-de-France")
      academy = create(:academy, academy_region: region)
      dept_in = Department.create!(academy:, name: "Paris", code: "75")
      other_region = create(:academy_region, name: "Auvergne-Rhône-Alpes")
      other_academy = create(:academy, name: "Académie de Lyon", email_domain: "ac-lyon.fr",
                                       academy_region: other_region)
      dept_out = Department.create!(academy: other_academy, name: "Rhône", code: "69")
      statistician = create(:academy_region_statistician, academy_region: region)

      assert Acl::Reporting.new(user: statistician, params: { department: [ dept_in.name ] }).allowed?
      refute Acl::Reporting.new(user: statistician, params: { department: [ dept_out.name ] }).allowed?
    end
  end
end
