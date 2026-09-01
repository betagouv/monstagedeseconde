require 'test_helper'

class CorporationTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
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

  test "should belong to multi_corporation" do
    assoc = Corporation.reflect_on_association(:multi_corporation)
    assert_equal :belongs_to, assoc.macro
  end

  test "#send_multi_agreement_signature_invitation" do
    internship_agreement = create(:multi_internship_agreement)
    corporation = internship_agreement.internship_offer.corporations.first

    assert_emails 1 do
      corporation.send_multi_agreement_signature_invitation(
        internship_agreement_ids: [internship_agreement.id]
      )
    end
  end

  test "#send_multi_agreement_signature_invitation but corporation does not match with internship agreement" do
    corporation = create(:corporation)
    internship_agreement = create(:multi_internship_agreement)

    assert_emails 0 do
      corporation.send_multi_agreement_signature_invitation(
        internship_agreement_ids: [internship_agreement.id]
      )
    end
  end

  test "period must be 1, 2 or nil" do
    @corporation.period = 3
    refute @corporation.valid?
    assert @corporation.errors[:period].present?

    [1, 2, nil].each do |valid_period|
      @corporation.period = valid_period
      assert @corporation.valid?, "period #{valid_period.inspect} should be valid"
    end
  end

  test "period is unique per multi_corporation with an explicit message" do
    multi_corporation = create(:multi_corporation)
    multi_corporation.corporations.destroy_all
    create(:corporation, multi_corporation:, period: 1)

    duplicate = build(:corporation, multi_corporation:, period: 1)
    refute duplicate.valid?
    assert_includes duplicate.errors[:period],
                    "cette période est déjà couverte par l'autre structure"
  end

  test "the same period is allowed across different multi_corporations" do
    first = create(:multi_corporation)
    first.corporations.destroy_all
    second = create(:multi_corporation)
    second.corporations.destroy_all
    create(:corporation, multi_corporation: first, period: 1)

    other = build(:corporation, multi_corporation: second, period: 1)
    assert other.valid?
  end

  test "several nil periods are allowed in the same multi_corporation (legacy compat)" do
    multi_corporation = create(:multi_corporation)
    multi_corporation.corporations.destroy_all
    create(:corporation, multi_corporation:, period: nil)

    another = build(:corporation, multi_corporation:, period: nil)
    assert another.valid?
  end
end