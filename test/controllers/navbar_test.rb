require 'test_helper'

class NavbarTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @school = create(:school, :with_school_manager)
  end

  test 'visitor navbar' do
    get root_path
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
  end

  test 'employer' do
    employer = create(:employer)
    sign_in(employer)
    get employer.custom_dashboard_path
    assert_select('li a.fr-link.mr-4', text: 'Mes offres', count: 1)
    assert_select('li a.fr-link.mr-4', text: 'Candidatures', count: 1)
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
    assert_select('li a.dropdown-item', text: 'Espaces', count: 1)
    assert_select('li a.dropdown-item', text: 'Equipe'.capitalize, count: 1)
    assert_select('li a.dropdown-item', text: 'Mon profil', count: 1)
  end

  test 'main_teacher' do
    main_teacher = create(:main_teacher,
                          school: @school,
                          class_room: create(:class_room, school: @school))
    sign_in(main_teacher)
    get dashboard_school_class_rooms_path(@school)
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
    assert_select('li a.dropdown-item', text: 'Mon profil', count: 1)
  end

  test 'other' do
    skip "since no 'other' status anymore"
    other = create(:other, school: @school)
    create(:class_room, school: @school)
    sign_in(other)
    get other.custom_dashboard_path
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
    assert_select('li a.dropdown-item', text: 'Mon profil', count: 1)
  end

  test 'operator' do
    operator = create(:user_operator)
    sign_in(operator)
    get operator.custom_dashboard_path
    # assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
  end

  test 'school_manager' do
    school_manager = @school.school_manager
    sign_in(school_manager)
    get dashboard_school_class_rooms_path(@school)

    assert_select('li a.fr-link.mr-4', text: 'Mon établissement', count: 1)
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
    assert_select('li a.dropdown-item', text: 'Mon profil', count: 1)
  end

  test 'student' do
    student = create(:student)
    sign_in(student)
    get student.custom_dashboard_path
    assert_select('li a.fr-link.mr-4', text: 'Recherche', count: 1)
    assert_select('li a.fr-link.mr-4', text: 'Candidatures', count: 1)
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
    assert_select('li a.dropdown-item', text: 'Favoris', count: 1)
    assert_select('li a.dropdown-item', text: 'Mon profil', count: 1)
  end

  test 'teacher' do
    teacher = create(:teacher,
                     school: @school,
                     class_room: create(:class_room, school: @school))
    sign_in(teacher)
    get dashboard_school_class_rooms_path(@school)
    assert_select('li a.fr-link.mr-4', text: 'Mon établissement', count: 1)
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
    assert_select('li a.dropdown-item', text: 'Mon profil', count: 1)
  end

  test 'statistician' do
    statistician = create(:statistician)
    sign_in(statistician)
    get statistician.custom_dashboard_path
    assert_select('li a.fr-link.mr-4', text: 'Statistiques', count: 1)
    assert_select('li a.fr-link.mr-4', text: 'Mes offres', count: 1)
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
    assert_select('li a.dropdown-item', text: 'Mon profil', count: 1)
  end

  test 'ministry statistician' do
    ministry_statistician = create(:ministry_statistician)
    sign_in(ministry_statistician)
    get ministry_statistician.custom_dashboard_path
    assert_select('li a.fr-link.mr-4', text: 'Statistiques', count: 1)
    assert_select('li a.fr-link.mr-4', text: 'Mes offres', count: 1)
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
    assert_select('li a.dropdown-item', text: 'Mon profil', count: 1)
  end

  test 'education statistician' do
    education_statistician = create(:education_statistician)
    sign_in(education_statistician)
    get education_statistician.custom_dashboard_path
    assert_select('li a.fr-link.mr-4', text: 'Statistiques', count: 1)
    assert_select('li a.fr-link.mr-4', text: 'Mes offres', count: 1)
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
    assert_select('li a.dropdown-item', text: 'Mon profil', count: 1)
  end

  test 'admin' do
    admin = create(:god)
    sign_in(admin)
    get root_path
    assert_select('li a.fr-link.mr-4', text: 'Admin', count: 1)
    assert_select('li a.fr-btn', text: 'Mon espace', count: 1)
  end
end
