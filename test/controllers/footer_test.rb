# frozen_string_literal: true

require 'test_helper'

class FooterTest < ActionDispatch::IntegrationTest

  test 'presence of footer links within valid rg2a footer' do
    get root_path

    # TODO bring content back
    # assert_select('a[href=?]', 'https://incubateur.anct.gouv.fr/')
    assert_select('a[href=?]', mentions_legales_path)
    assert_select('a[href=?]', politique_de_confidentialite_path)
    # assert_select('a[href=?]', conditions_d_utilisation_path)
    # assert_select('a[href=?]', accessibilite_path)

  end
end
