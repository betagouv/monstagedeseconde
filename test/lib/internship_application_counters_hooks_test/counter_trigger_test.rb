# frozen_string_literal: true

require "test_helper"

# Vérifie que les compteurs se déclenchent exactement une fois par transition,
# via after_commit (pas after_save), sans double comptage dû aux sous-classes STI.
class CounterTriggerTest < ActiveSupport::TestCase
  setup do
    @student = create(:student, :male)
    @internship_offer = create(:weekly_internship_offer_2nde)
    @recalculate_call_count = 0
    counter_test = self

    InternshipOfferStats.class_eval do
      alias_method :original_recalculate, :recalculate
      define_method(:recalculate) do
        counter_test.instance_variable_set(
          :@recalculate_call_count,
          counter_test.instance_variable_get(:@recalculate_call_count) + 1
        )
        original_recalculate
      end
    end
  end

  teardown do
    InternshipOfferStats.class_eval do
      alias_method :recalculate, :original_recalculate
      remove_method :original_recalculate
    end
  end

  test "les stats sont recalculées exactement une fois lors de la création d'une candidature" do
    create(:weekly_internship_application,
           internship_offer: @internship_offer,
           student: @student)
    assert_equal 1, @recalculate_call_count,
                 "recalculate doit être appelé exactement 1 fois, appelé #{@recalculate_call_count} fois (bug: double after_save STI)"
  end

  test "les stats sont recalculées exactement une fois lors d'une transition d'état" do
    application = create(:weekly_internship_application,
                         internship_offer: @internship_offer,
                         student: @student)
    @recalculate_call_count = 0 # reset après création

    application.reject!

    assert_equal 1, @recalculate_call_count,
                 "recalculate doit être appelé exactement 1 fois après reject!, appelé #{@recalculate_call_count} fois"
  end
end
