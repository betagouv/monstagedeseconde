require 'application_system_test_case'

class AccountEditTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'as a student, I cannot see my scrambled email' do
    student = create(:student)
    scrambled_ine = Digest::SHA1.hexdigest(student.ine)
    scrambled_email = "#{scrambled_ine}@#{student.try(:school).try(:code_uai)}.fr"
    student.update_columns(email: scrambled_email)

    sign_in(student)
    visit account_path

    assert find(:css, '#user_email').value == ''
  end

  test 'as a student, I cant see my email' do
    student = create(:student)

    sign_in(student)
    visit account_path

    assert find(:css, '#user_email').value == student.email
  end

  test 'as a student, I can update my phone number' do
    student = create(:student, phone: '+330623042585')

    sign_in(student)
    visit account_path
    phone_suffix = find(:css, '#user_phone_suffix')
    phone_suffix.fill_in(with: '0622558877')
    click_on 'Enregistrer mes informations'
    assert student.reload.phone == '+330622558877'
  end

  test 'as a student, I cannot update my classe, first_name, last_name, birth_day' do
    student = create(:student)

    sign_in(student)
    visit account_path

    assert find(:css, '#user_first_name').readonly?
    assert find(:css, '#user_last_name').readonly?
    assert find(:css, '#user_birth_date').readonly?
    assert find(:css, '#user_class_room').readonly?
    refute find(:css, '#user_email').readonly?
    refute find(:css, '#user_phone_suffix').readonly?
  end

  test 'as an employer, I can update all accounts fields' do
    employer = create(:employer)
    email = employer.email

    sign_in(employer)
    visit account_path

    fill_in('user[first_name]', with: 'Jean')
    fill_in('user[last_name]', with: 'Dupont')
    fill_in('user[email]', with: 'test@parole.fr')
    fill_in('user[phone_suffix]', with: '0622558877')
    click_on 'Enregistrer mes informations'
    employer.reload
    assert employer.first_name == 'Jean'
    assert employer.last_name == 'Dupont'
    assert employer.email == email
    assert employer.phone == '+330622558877'
    assert_text 'Pour confirmer le changement d’adresse électronique,'
  end

  test 'as a statistician, I can update all accounts fields but the email' do
    statistician = create(:ministry_statistician)

    sign_in(statistician)
    visit account_path

    fill_in('user[first_name]', with: 'Jean')
    fill_in('user[last_name]', with: 'Dupont')
    click_on 'Enregistrer mes informations'
    statistician.reload
    assert statistician.first_name == 'Jean'
    assert statistician.last_name == 'Dupont'
    assert find(:css, '#user_email').readonly?
  end

  test 'as a teacher, I can update all accounts fields but the email' do
    skip 'waiting an answer for class room choosing'
  end
end
