# frozen_string_literal: true

require "test_helper"

class TroisiemeDuplicationPeriodTest < ActiveSupport::TestCase
  class DummyClass
    include TroisiemeDuplicationPeriod
  end

  setup do
    @dummy = DummyClass.new
  end

  test "troisieme_no_dates_available? is true during the forbidden period" do
    travel_to Date.new(2026, 6, 10) do
      assert @dummy.troisieme_no_dates_available?
    end
  end

  test "troisieme_no_dates_available? is false outside the forbidden period" do
    travel_to Date.new(2026, 7, 2) do
      assert_not @dummy.troisieme_no_dates_available?
    end
  end

  test "troisieme_no_dates_available_message explains when dates reopen" do
    travel_to Date.new(2026, 6, 10) do
      assert_equal(
        "Aucune semaine de stage n'est actuellement disponible pour les élèves de 3ème (et 4ème). " \
        "Les semaines de stage pour la prochaine année scolaire seront ouvertes à partir du 1er juillet.",
        @dummy.troisieme_no_dates_available_message
      )
    end
  end
end
