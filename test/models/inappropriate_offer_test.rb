require "test_helper"

class InappropriateOfferTest < ActiveSupport::TestCase
  test '"valid" factory' do
    inappropriate_offer = build(:inappropriate_offer)
    assert inappropriate_offer.valid?
    inappropriate_offer.save!
    assert inappropriate_offer.persisted?
  end

  test "missing details is invalid" do
    inappropriate_offer = build(:inappropriate_offer, details: nil)
    assert inappropriate_offer.invalid?
    assert_includes inappropriate_offer.errors[:details], "doit être rempli(e)"
  end

  test "too short details is invalid" do
    inappropriate_offer = build(:inappropriate_offer, details: "Too short")
    assert inappropriate_offer.invalid?
    assert_includes inappropriate_offer.errors[:details], "est trop court (au moins 10 caractères)"
  end

  test "too long details is invalid" do
    inappropriate_offer = build(:inappropriate_offer, details: "A" * 351)
    assert inappropriate_offer.invalid?
    assert_includes inappropriate_offer.errors[:details], "est trop long (pas plus de 350 caractères)"
  end

  test "missing user is valid" do
    inappropriate_offer = build(:inappropriate_offer, user: nil)
    assert inappropriate_offer.valid?
  end

end
