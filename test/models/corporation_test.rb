require 'test_helper'

class CorporationTest < ActiveSupport::TestCase
  def setup
    @corporation = build(:corporation)
  end

  test "should be valid with valid attributes" do
    assert @corporation.valid?
  end

  test "should require a name" do
    @corporation.employer_name = ""
    assert_not @corporation.valid?
  end

  test "should require siret to be present and 14 characters" do
    @corporation.siret = nil
    assert_not @corporation.valid?
    @corporation.siret = "123"
    assert_not @corporation.valid?
    @corporation.siret = "12345678901234"
    @corporation.valid? # triggers validation
    assert_equal 14, @corporation.siret.length
  end

  test "should require corporation_name to be present and <= 120 characters" do
    @corporation.corporation_name = nil
    assert_not @corporation.valid?
    @corporation.corporation_name = "a" * 121
    assert_not @corporation.valid?
    @corporation.corporation_name = "Employer"
    assert @corporation.valid?
  end

  test "should require corporation_address to be present and <= 250 characters" do
    @corporation.corporation_address = nil
    assert_not @corporation.valid?
    @corporation.corporation_address = "a" * 251
    assert_not @corporation.valid?
    @corporation.corporation_address = "123 Main St"
    assert @corporation.valid?
  end

  test "should require city, zipcode, and street for signatory address" do
    @corporation.corporation_city = nil
    assert_not @corporation.valid?
    @corporation.corporation_zipcode = nil
    assert_not @corporation.valid?
    @corporation.corporation_street = nil
    assert_not @corporation.valid?
  end

  test "should require internship_city, internship_zipcode, internship_street, internship_phone" do
    @corporation.internship_city = nil
    assert_not @corporation.valid?
    @corporation.internship_zipcode = nil
    assert_not @corporation.valid?
    @corporation.internship_street = nil
    assert_not @corporation.valid?
    @corporation.internship_phone = nil
    assert_not @corporation.valid?
  end

  test "should require tutor_name, tutor_role_in_company, tutor_email, tutor_phone" do
    @corporation.tutor_name = nil
    assert_not @corporation.valid?
    @corporation.tutor_role_in_company = nil
    assert_not @corporation.valid?
    @corporation.tutor_email = nil
    assert_not @corporation.valid?
    @corporation.tutor_phone = nil
    assert_not @corporation.valid?
  end

  test "should validate tutor_email format" do
    @corporation.tutor_email = "invalid_email"
    assert_not @corporation.valid?
    @corporation.tutor_email = "valid@email.com"
    assert @corporation.valid?
  end

  test "should require sector_id" do
    @corporation.sector_id = nil
    assert_not @corporation.valid?
  end

  test "should belong to multi_corporation" do
    assoc = Corporation.reflect_on_association(:multi_corporation)
    assert_equal :belongs_to, assoc.macro
  end

  test "should belong to sector (optional)" do
    assoc = Corporation.reflect_on_association(:sector)
    assert_equal :belongs_to, assoc.macro
    assert assoc.options[:optional]
  end
end