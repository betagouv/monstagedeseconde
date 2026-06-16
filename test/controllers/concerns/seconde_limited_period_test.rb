# frozen_string_literal: true

require "test_helper"

class SecondeLimitedPeriodTest < ActiveSupport::TestCase
  class DummyClass
    include SecondeLimitedPeriod
  end

  setup do
    @dummy = DummyClass.new
  end

  # first_monday 2026 = 15 juin, last_monday 2026 = 22 juin

  test "seconde_first_week_unavailable? is false before first_monday" do
    travel_to Date.new(2026, 6, 14) do
      assert_not @dummy.seconde_first_week_unavailable?
    end
  end

  test "seconde_first_week_unavailable? is true on first_monday" do
    travel_to Date.new(2026, 6, 15) do
      assert @dummy.seconde_first_week_unavailable?
    end
  end

  test "seconde_first_week_unavailable? is true between first_monday and last_monday" do
    travel_to Date.new(2026, 6, 19) do
      assert @dummy.seconde_first_week_unavailable?
    end
  end

  test "seconde_first_week_unavailable? is true on last_monday" do
    travel_to Date.new(2026, 6, 22) do
      assert @dummy.seconde_first_week_unavailable?
    end
  end

  test "seconde_first_week_unavailable? is false on July 1st" do
    travel_to Date.new(2026, 7, 1) do
      assert_not @dummy.seconde_first_week_unavailable?
    end
  end

  test "seconde_no_new_offers? is false before last_monday" do
    travel_to Date.new(2026, 6, 21) do
      assert_not @dummy.seconde_no_new_offers?
    end
  end

  test "seconde_no_new_offers? is true on last_monday" do
    travel_to Date.new(2026, 6, 22) do
      assert @dummy.seconde_no_new_offers?
    end
  end

  test "seconde_no_new_offers? is false on July 1st" do
    travel_to Date.new(2026, 7, 1) do
      assert_not @dummy.seconde_no_new_offers?
    end
  end
end
