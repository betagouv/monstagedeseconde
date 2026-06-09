require 'test_helper'

class SchoolStatTest < ActiveSupport::TestCase
  setup do
    @school = create(:school)
  end

  test 'is valid with required attributes' do
    stat = SchoolStat.new(school: @school, date_reference: Date.current)
    assert stat.valid?
  end

  test 'requires a date_reference' do
    stat = SchoolStat.new(school: @school)
    refute stat.valid?
    assert_includes stat.errors.attribute_names, :date_reference
  end

  test 'requires a school' do
    stat = SchoolStat.new(date_reference: Date.current)
    refute stat.valid?
  end

  test 'enforces uniqueness of school + date_reference at the database level' do
    SchoolStat.create!(school: @school, date_reference: Date.current)
    assert_raises(ActiveRecord::RecordNotUnique) do
      SchoolStat.create!(school: @school, date_reference: Date.current)
    end
  end
end
