require "test_helper"

class DepartmentTest < ActiveSupport::TestCase
  test ".lookup_by_zipcode" do
    create(:department, code: "2A", name: "Corse-du-Sud")
    create(:department, code: "2B", name: "Haute-Corse")
    create(:department, code: "19", name: "Corrèze")
    assert_equal "Haute-Corse", Department.lookup_by_zipcode(zipcode: "20200")
    assert_equal "Corse-du-Sud", Department.lookup_by_zipcode(zipcode: "20000")
    assert_equal "Corrèze", Department.lookup_by_zipcode(zipcode: "19001")

  end
end
