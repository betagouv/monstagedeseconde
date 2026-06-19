# frozen_string_literal: true

require 'test_helper'

class FooterTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'presence of footer links within valid rg2a footer' do
    get root_path

    assert_select('a[href=?]', mentions_legales_path)
    assert_select('a[href=?]', politique_de_confidentialite_path)
    # assert_select('a[href=?]', conditions_d_utilisation_path)
    # assert_select('a[href=?]', accessibilite_path)
  end

  test 'contact link is hidden in footer for a visitor on the public homepage' do
    get root_path

    assert_select "a[href='#{contact_path}']", count: 0
  end

  test 'contact link is hidden on the student login page' do
    get student_login_path

    assert_select "a[href='#{contact_path}']", count: 0
  end

  test 'contact link is shown on the pro, school management and referent login pages' do
    [ pro_login_path, school_management_login_path, statistician_login_path ].each do |path|
      get path

      assert_select "a[href='#{contact_path}']", { minimum: 1 },
                    "expected the contact link to be present on #{path}"
    end
  end

  test 'contact link is hidden in footer for a signed-in student' do
    sign_in create(:student)
    get root_path

    assert_select "a[href='#{contact_path}']", count: 0
  end

  test 'contact link is shown in footer for a signed-in employer' do
    sign_in create(:employer)
    get root_path

    assert_select "a[href='#{contact_path}']", minimum: 1
  end
end
