# frozen_string_literal: true

require "test_helper"

module Users
  class SchoolManagementSearchTest < ActiveSupport::TestCase
    setup do
      @school = create(:school, code_uai: "0750001Z")
      @sm     = create(:school_manager,
                       first_name: "Alice",
                       last_name:  "Dupont",
                       school:     @school)
    end

    test "search_by_query matches on last_name" do
      assert_includes Users::SchoolManagement.search_by_query("Dupont"), @sm
    end

    test "search_by_query matches on first_name" do
      assert_includes Users::SchoolManagement.search_by_query("Alice"), @sm
    end

    test "search_by_query matches on email" do
      assert_includes Users::SchoolManagement.search_by_query(@sm.email[0..5]), @sm
    end

    test "search_by_query matches on school code_uai" do
      assert_includes Users::SchoolManagement.search_by_query("0750001Z"), @sm
    end

    test "search_by_query is case-insensitive" do
      assert_includes Users::SchoolManagement.search_by_query("dupont"), @sm
      assert_includes Users::SchoolManagement.search_by_query("DUPONT"), @sm
    end

    test "search_by_query returns nothing on non-matching query" do
      assert_empty Users::SchoolManagement.search_by_query("zzzmatch999")
    end

    test "search_by_query does not return discarded users" do
      @sm.discard!
      assert_empty Users::SchoolManagement.kept.search_by_query("Dupont")
    end
  end
end
