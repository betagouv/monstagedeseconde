require 'test_helper'

class ClassRoomTest < ActiveSupport::TestCase
  test 'FactoryBot works with build' do
    class_room = build(:class_room)
    assert class_room.valid?
  end
  test 'FactoryBot works with create' do
    assert_difference 'ClassRoom.count', 1 do
      create(:class_room)
    end
  end
end
