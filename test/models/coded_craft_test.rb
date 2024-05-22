require "test_helper"

class CodedCraftTest < ActiveSupport::TestCase
  setup do
   @craft = create(:craft)
   @detailed_craft_1 = create(:detailed_craft, craft: @craft)
   @detailed_craft_2 = create(:detailed_craft, craft: @craft)
   @coded_craft_1 = create(:coded_craft, detailed_craft: @detailed_craft_1)
   @coded_craft_2 = create(:coded_craft, detailed_craft: @detailed_craft_1)
   @coded_craft_3 = create(:coded_craft, detailed_craft: @detailed_craft_2)
   @coded_craft_4 = create(:coded_craft, detailed_craft: @detailed_craft_2)
   @coded_craft_5 = create(:coded_craft)
  end

  test 'factories' do
    refute @craft.nil?
    assert_equal 2, Craft.count
    assert_equal 3, DetailedCraft.count
    assert_equal 5, CodedCraft.count
  end

  test '#siblings when level 0' do
    string, list = @coded_craft_4.siblings(level: 0)
    assert_equal '', string
    assert_equal [@coded_craft_4], list
  end

  test '#siblings when level 1' do
    string, list = @coded_craft_4.siblings(level: 1)
    assert_equal @detailed_craft_2.name, string
    assert_equal 2, list.size
    assert @coded_craft_4.in?(list)
    assert @coded_craft_3.in?(list)
  end

  test '#siblings when level 2' do
    string, list = @coded_craft_4.siblings(level: 2)
    assert_equal @craft.name, string
    assert_equal 4, list.size
    assert @coded_craft_1.in?(list)
    assert @coded_craft_2.in?(list)
    assert @coded_craft_3.in?(list)
    assert @coded_craft_4.in?(list)
  end

  test '#siblings when level 3' do
    string, list = @coded_craft_4.siblings(level: 3)
    assert_equal @craft.craft_field.name, string
    assert_equal 4, list.size
    assert @coded_craft_1.in?(list)
    assert @coded_craft_2.in?(list)
    assert @coded_craft_3.in?(list)
    assert @coded_craft_4.in?(list)
  end
end
