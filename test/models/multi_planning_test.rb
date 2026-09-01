require 'test_helper'

class MultiPlanningTest < ActiveSupport::TestCase

  test '#daily_planning_2? is false by default' do
    refute MultiPlanning.new.daily_planning_2?
  end

  test '#daily_planning_2? is true when daily_hours_2 has at least one value' do
    planning = MultiPlanning.new(daily_hours_2: { 'lundi' => ['09:00', '17:00'] })
    assert planning.daily_planning_2?
  end

  test '#daily_planning_2? is false when daily_hours_2 only contains blanks' do
    planning = MultiPlanning.new(daily_hours_2: { 'lundi' => ['', ''] })
    refute planning.daily_planning_2?
  end

  test '#has_different_period_2_hours? is false by default' do
    refute MultiPlanning.new.has_different_period_2_hours?
  end

  test '#has_different_period_2_hours? is true with weekly_hours_2' do
    planning = MultiPlanning.new(weekly_hours_2: ['09:00', '17:00'])
    assert planning.has_different_period_2_hours?
  end

  test '#has_different_period_2_hours? is true with daily_hours_2' do
    planning = MultiPlanning.new(daily_hours_2: { 'mardi' => ['08:00', '12:00'] })
    assert planning.has_different_period_2_hours?
  end
end
