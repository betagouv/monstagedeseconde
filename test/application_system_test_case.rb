# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

# this app is BUILT FOR TWO PLATFORM : web/mobile
#
# our APPROACH/FOCUS is #1 web tech (easy of use/velocity)
#     + focus on mobile rendering first (easy with RWD to extend to desktop)
#
# DEPENDING OF THE TARGETED PLAFORM, FEATURES MAY DIFFER, so does testing
# e2e testing is addressed for both platform with focus on maintenance
# * mobile only shortcut: ./infra/system_mobile.sh [only mobile, capybara with a selenium driver, driving an chrome_headless + emulator]
# * desktop only shortcut: ./infra/system_desktop.sh [only desktop, capybara with a selenium driver, driving an chrome_headless]
#
# saying that, THE SUITE MUST BE CONSTRAINED TO ONLY RUN EACH KIND OF TEST (rails takes them all)
# to do so we use minitest TEST_OPTS flags :
# --name='pattern_to_run_tests_matching_a_pattern'
# --exclude='pattern_to_skip_tests_matching_a_pattern'
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  CAPYBARA_DRIVER = :selenium

  # usage: BROWSER=chrome|headless_chrome|firefox rails test:system TESTOPTS='--exclude /USE_IPHONE_EMULATION/'
  CAPYBARA_BROWSER = ENV.fetch('BROWSER') { 'headless_chrome' }.to_sym
  # usage: USE_IPHONE_EMULATION=true (or undef) rails test:system TESTOPTS='--name /^USE_IPHONE_EMULATION/'
  CAPYBARA_EMULATE_MOBILE = ENV.fetch('USE_IPHONE_EMULATION') { false }

  driven_by CAPYBARA_DRIVER, using: CAPYBARA_BROWSER do |driver_opts|
    # when ENV['USE_IPHONE_EMULATION'], use chrome emulation with iPhone 6
    driver_opts.add_emulation(device_name: 'iPhone 6') if CAPYBARA_EMULATE_MOBILE
    driver_opts.add_argument('--disable-search-engine-choice-screen')
  end

  include Devise::Test::IntegrationHelpers
  include Html5Validator

  # Les pages React (recherche d'offres) et les turbo_streams peuvent mettre
  # plus de 2 s (défaut Capybara) à se rendre, surtout sur CI.
  Capybara.default_max_wait_time = 10

  def setup
    stub_request(:any, %r{data.geopf.fr/geocodage})
      .to_return(status: 200, body: File.read(Rails.root.join(*%w[test
                                                                  fixtures
                                                                  files
                                                                  12-rue-taine-paris.json])))

    stub_request(:any, /recherche-entreprises.api.gouv.fr/)
      .to_return(status: 200, body: '')
  end

  def confirm_next_dialog
    evaluate_script("Turbo.setConfirmMethod(() => Promise.resolve(true))")
  end

  # La modale « annonce internats » (InternshipOfferResults.jsx) s'ouvre à chaque
  # montage du composant de résultats tant que le flag localStorage n'est pas posé
  # — toujours le cas dans une session Selenium fraîche — et son backdrop
  # intercepte alors tous les clics de la page.
  def dismiss_boarding_house_announcement
    execute_script("try { localStorage.setItem('boardingHouseAnnouncementDismissed', '1') } catch (e) {}")
    return unless page.has_css?('#boarding-house-announcement-title', wait: 1)

    click_button 'OK'
    assert_no_selector '#boarding-house-announcement-title'
  end

  def visit_offers_index(path)
    visit path
    dismiss_boarding_house_announcement
  end

  # « Espaces », « Equipe » et « Mon profil » sont dans le dropdown « Mon espace »
  # de la navbar (fermé par défaut).
  def open_my_space_menu
    click_on 'Mon espace'
    find('ul[data-dropdown-target="menu"]', visible: :visible)
  end

  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end

  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
