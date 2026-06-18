# frozen_string_literal: true

require "test_helper"

class SchoolSearchTest < ActiveSupport::TestCase
  test "search_by_query matches on name" do
    school = create(:school, name: "Lycée Fermat Toulouse")
    results = School.search_by_query("Fermat")
    assert_includes results, school
  end

  test "search_by_query matches on city" do
    school = create(:school, city: "Bordeaux")
    results = School.search_by_query("Bordeaux")
    assert_includes results, school
  end

  test "search_by_query matches on code_uai" do
    school = create(:school, code_uai: "0330001A")
    results = School.search_by_query("0330001A")
    assert_includes results, school
  end

  test "search_by_query is case-insensitive" do
    school = create(:school, name: "Lycée Victor Hugo")
    assert_includes School.search_by_query("victor hugo"), school
    assert_includes School.search_by_query("VICTOR HUGO"), school
  end

  test "search_by_query returns nothing on non-matching query" do
    create(:school, name: "École unique")
    assert_empty School.search_by_query("zzzmatch999")
  end
end
