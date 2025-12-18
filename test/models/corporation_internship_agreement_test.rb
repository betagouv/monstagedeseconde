require "test_helper"

class CorporationInternshipAgreementTest < ActiveSupport::TestCase
  def setup
    @corporation = create(:corporation)
    @internship_agreement = create(:internship_agreement)
  end

  test 'factory is valid' do
    cia = build(:corporation_internship_agreement)
    assert cia.valid?
  end

  test "should be valid with valid attributes" do
    cia = CorporationInternshipAgreement.new(
      corporation: @corporation,
      internship_agreement: @internship_agreement
    )
    assert cia.valid?
  end

  test "should require a corporation" do
    cia = CorporationInternshipAgreement.new(
      internship_agreement: @internship_agreement
    )
    refute cia.valid?
    assert_includes cia.errors[:corporation], "doit exister"
  end

  test "should require an internship_agreement" do
    cia = CorporationInternshipAgreement.new(
      corporation: @corporation
    )
    refute cia.valid?
    assert_includes cia.errors[:internship_agreement], "doit exister"
  end
end