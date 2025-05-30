# frozen_string_literal: true

require 'test_helper'
module Users
  class SchoolManagementTest < ActiveSupport::TestCase
    setup do
      @url_helpers = Rails.application.routes.url_helpers
    end

    test 'validates other fields' do
      school_manager = Users::SchoolManagement.new(role: :teacher)

      assert school_manager.invalid?
      assert_not_empty school_manager.errors[:first_name]
      assert_not_empty school_manager.errors[:last_name]
      assert_not_empty school_manager.errors[:email]
      assert_not_empty school_manager.errors[:accept_terms]
      assert_not_empty school_manager.errors[:password]
    end

    test 'creation succeed' do
      school = build(:school)
      school_manager = Users::SchoolManagement.new(
        role: :school_manager,
        email: "jean-pierre@#{school.email_domain_name}",
        password: 'tototo1Max!!',
        first_name: 'Chef',
        last_name: 'Etablissement',
        phone: '+330602030405',
        school:,
        accept_terms: true
      )
      assert school_manager.valid?
    end

    test 'has_many main_teachers' do
      school = create(:school)
      school_manager = create(:school_manager, school:)
      main_teacher = create(:main_teacher, school:)

      school_manager.reload

      assert_includes school_manager.main_teachers.entries, main_teacher
    end

    # ===>  kept because of the stub usage
    # test 'change school notify new school_manager' do
    #   school_1 = create(:school)
    #   school_2 = create(:school)
    #   school_manager_1 = create(:school_manager, school: school_1)
    #   school_manager_2 = create(:school_manager, school: school_2)

    #   %i[teacher other main_teacher].each do |role_change_notifier|
    #     user = create(role_change_notifier, school: school_1)
    #     user.school = school_2

    #     mock_mail = Minitest::Mock.new
    #     mock_mail.expect(:deliver_later, true)
    #     SchoolManagerMailer.stub :new_member, mock_mail do
    #       user.save!
    #     end
    #     mock_mail.verify
    #   end
    # end

    test '#management_representative' do
      school = create(:school)
      assert_nil school.management_representative
      create(:main_teacher, school:)
      assert_equal school.main_teachers.first.id, school.management_representative.id
      create(:teacher, school:)
      assert_equal school.main_teachers.first.id, school.management_representative.id
      other = create(:other, school:)
      assert_equal other.id, school.management_representative.id
      cpe = create(:cpe, school:)
      assert_equal cpe.id, school.management_representative.id
      admin_officer = create(:admin_officer, school:)
      assert_equal admin_officer.id, school.management_representative.id
      create(:school_manager, school:)
      assert_equal admin_officer.id, school.management_representative.id
    end
  end
end
