# frozen_string_literal: true

require 'test_helper'
module Users
  class SchoolManagementTest < ActiveSupport::TestCase
    setup do
      @url_helpers = Rails.application.routes.url_helpers
    end

    test '#official_uai_email_address' do
      other_attributes = { first_name: 'Carl',
                           last_name: 'Orloff',
                           role: :school_manager,
                           confirmed_at: Time.zone.now,
                           accept_terms: true,
                           school: create(:school),
                           password: '12456abcDEF?/ç' }
      school_manager = Users::SchoolManagement.new(
        other_attributes.merge(
          email: 'chef@etablissement.com'
        )
      )
      assert school_manager.invalid?
      assert_not_empty school_manager.errors[:email]

      school_manager = Users::SchoolManagement.new(
        other_attributes.merge(
          email: 'ce.123456@ac-paris.fr'
        )
      )
      assert school_manager.invalid?
      assert_not_empty school_manager.errors[:email]

      school_manager = Users::SchoolManagement.new(
        other_attributes.merge(
          email: 'ce.1234567x@ac-paris.fr'
        )
      )
      assert school_manager.valid?

      school_manager = Users::SchoolManagement.new(
        other_attributes.merge(
          email: 'ce.1234567@ac-paris.fr'
        )
      )
      assert school_manager.valid?
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

    test 'change school notify new school_manager' do
      school_1 = create(:school)
      school_2 = create(:school)
      school_manager_1 = create(:school_manager, school: school_1)
      school_manager_2 = create(:school_manager, school: school_2)

      %i[teacher other main_teacher].each do |role_change_notifier|
        user = create(role_change_notifier, school: school_1)
        user.school = school_2

        mock_mail = Minitest::Mock.new
        mock_mail.expect(:deliver_later, true)
        SchoolManagerMailer.stub :new_member, mock_mail do
          user.save!
        end
        mock_mail.verify
      end
    end

    test '#valid_academy_email_address?' do
      school = create(:school, zipcode: '75012')
      assert build(:school_manager, email: 'ce.1122334x@ac-paris.fr', school:).valid?
      refute build(:school_manager, email: 'ce.1122334x@ac-caen.fr', school:).valid?

      school = create(:school, zipcode: '61252', city: 'Argentan', code_uai: '0612345A')
      assert build(:school_manager, email: 'ce.1122334x@ac-normandie.fr', school:).valid?
      assert build(:school_manager, email: 'ce.1122334x@ac-caen.fr', school:).valid?
      refute build(:school_manager, email: 'ce.1122334x@ac-paris.fr', school:).valid?
      refute build(:school_manager, email: 'ce.1122334x@ac-test.fr', school:).valid?
    end
  end
end
