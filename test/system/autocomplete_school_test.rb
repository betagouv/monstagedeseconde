# frozen_string_literal: true

require 'application_system_test_case'

# La section « Mon établissement » du compte est désormais en lecture seule
# (app/views/users/_edit_school.html.slim) : l'établissement et la classe ne
# sont plus modifiables depuis cette page (rattachement géré par ailleurs :
# admin des personnels, synchronisation élèves).
class AutocompleteSchoolTest < ApplicationSystemTestCase
  setup do
    @default_school_name = 'Pasteur'
    @default_school_city = 'Mantes-la-Jolie'
    @default_school = create(:school, :with_school_manager, name: @default_school_name,
                                                            city: @default_school_city)
  end

  test 'school panel shows school manager school as read-only' do
    school_manager = @default_school.school_manager
    sign_in(school_manager)
    visit account_path(section: :school)
    within('.fr-tabs') do
      click_on 'Mon établissement'
    end

    school_select = find('select#school_name[disabled]')
    assert_equal @default_school_name,
                 school_select.find('option', text: @default_school_name).text
    assert_no_field 'Établissement ou commune'
    assert_no_selector '#user_class_room_id'
  end

  test 'school panel shows student school as read-only without class room choice' do
    student = create(:student, school: @default_school,
                               class_room: create(:class_room, school: @default_school))
    sign_in(student)
    visit account_path(section: :school)
    within('.fr-tabs') do
      click_on 'Mon établissement'
    end

    find('select#school_name[disabled]')
    assert_no_field 'Établissement ou commune'
    assert_no_selector '#user_class_room_id'
  end
end
