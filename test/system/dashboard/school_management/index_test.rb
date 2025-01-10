require 'application_system_test_case'
module Dashboard::SchoolManagement
  class IndexTest < ApplicationSystemTestCase
    test 'visiting the index' do
      school_manager = create(:school_manager, :college)
      assert school_manager.school.name.starts_with?('Collège')
      sign_in school_manager
      visit dashboard_school_management_root_path ???
      assert_selector 'h1', text: 'Gestion de l\'établissement'
    end
  end
end
