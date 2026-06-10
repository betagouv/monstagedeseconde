require "test_helper"
require "pretty_console"

class InternshipAgreementTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert build(:mono_internship_agreement).valid?
  end

  test "validates uniqueness of internship_application_id among kept records" do
    existing = create(:mono_internship_agreement)
    duplicate = build(:mono_internship_agreement,
                      internship_application: existing.internship_application)
    refute duplicate.valid?
    assert duplicate.errors[:internship_application_id].present?
  end

  test "allows a new agreement when previous one is discarded" do
    existing = create(:mono_internship_agreement)
    existing.update!(discarded_at: Time.current)
    duplicate = build(:mono_internship_agreement,
                      internship_application: existing.internship_application)
    assert duplicate.valid?
  end

  test "factory multi is valid" do
    assert build(:multi_internship_agreement).valid?
  end

  test "#roles_not_signed_yet" do
    internship_agreement = create(:mono_internship_agreement, aasm_state: :validated)
    assert_equal %w[school_manager employer student student_legal_representative],
                 internship_agreement.roles_not_signed_yet
    create(:signature,
           :school_manager,
           internship_agreement_id: internship_agreement.id)
    assert_equal %w[employer student student_legal_representative],
                 internship_agreement.roles_not_signed_yet
  end

  test "#notify_others_signatures_finished" do
    internship_agreement = create(:mono_internship_agreement, aasm_state: :validated)
    assert_changes -> { Signature.count }, from: 0, to: 1 do
      create(:signature,
             :school_manager,
             internship_agreement_id: internship_agreement.id)
    end
  end

  test "#ready_to_sign?" do
    internship_agreement = create(:mono_internship_agreement, aasm_state: :validated)
    assert internship_agreement.ready_to_sign?(user: internship_agreement.school_manager)
    create(:signature,
           :school_manager,
           internship_agreement_id: internship_agreement.id)

    refute internship_agreement.ready_to_sign?(user: internship_agreement.school_manager)
    assert internship_agreement.ready_to_sign?(user: internship_agreement.employer)

    create(:signature,
           :employer,
           internship_agreement_id: internship_agreement.id)

    refute internship_agreement.ready_to_sign?(user: internship_agreement.employer)

    internship_agreement_2 = create(:mono_internship_agreement, aasm_state: :signed_by_all)
    refute internship_agreement_2.ready_to_sign?(user: internship_agreement_2.school_manager)
  end

  test "#signed_by? starting with school_manager" do
    internship_agreement = create(:mono_internship_agreement, aasm_state: :validated)
    refute internship_agreement.signed_by?(user: internship_agreement.school_manager)
    create(:signature,
           :school_manager,
           internship_agreement_id: internship_agreement.id)
    assert internship_agreement.signed_by?(user: internship_agreement.school_manager)
    refute internship_agreement.signed_by?(user: internship_agreement.employer)
  end

  test "#signed_by? starting with employer" do
    internship_agreement = create(:mono_internship_agreement, aasm_state: :validated)
    refute internship_agreement.signed_by?(user: internship_agreement.employer)
    create(:signature,
           :employer,
           signator: internship_agreement.employer,
           internship_agreement_id: internship_agreement.id)
    assert internship_agreement.signed_by?(user: internship_agreement.employer)
    refute internship_agreement.signed_by?(user: internship_agreement.school_manager)
  end

  test "factory" do
    internship_agreement = build(:mono_internship_agreement)
    assert internship_agreement.valid?
    assert internship_agreement.save!
  end

  test "#school_management_representative" do
    internship_agreement = create(:mono_internship_agreement)
    internship_application = internship_agreement.internship_application
    school = internship_application.student.school
    assert_equal school.school_manager, school.management_representative
    assert_equal school.school_manager, internship_agreement.school_management_representative
    create(:cpe, school: school)
    assert_equal school.school_manager, internship_agreement.school_management_representative
    admin_officer = create(:admin_officer, school: school)
    assert_equal admin_officer, internship_agreement.school_management_representative
    cpe = create(:cpe, school: school)
    create(:signature, :cpe, user_id: cpe.id, internship_agreement_id: internship_agreement.id)
    assert_equal cpe, internship_agreement.school_management_representative
  end

  test "#missing_signatures_recipients" do
  skip "test will be ok when getting rid of Flipper :student_signature"
    internship_agreement = create(:mono_internship_agreement, aasm_state: :validated)
    internship_application = internship_agreement.internship_application
    student = internship_application.student
    school = student.school
    employer = internship_agreement.employer
    school_manager = school.school_manager
    assert_equal [ employer.email, school_manager.email, student.email ].sort,
                 internship_agreement.missing_signatures_recipients.sort

    create(:signature,
           :school_manager,
           internship_agreement_id: internship_agreement.id)
    assert_equal [ employer.email, student.email ].sort,
                 internship_agreement.missing_signatures_recipients.sort

    create(:signature,
           :employer,
           internship_agreement_id: internship_agreement.id)
    assert_equal [ student.email ],
                 internship_agreement.missing_signatures_recipients
    internship_agreement.sign!
    create(:signature,
           :student,
           internship_agreement_id: internship_agreement.id)
    assert_equal [],
                 internship_agreement.missing_signatures_recipients
    create(:signature,
           :student_legal_representative,
           internship_agreement_id: internship_agreement.id,
           user_id: internship_agreement.student.id)

    internship_agreement.sign!
    assert internship_agreement.reload.signed_by_all?
  end

  test "#sign creates agreement_to_sign (medium) and agreement_signed_by_another (low) when employer has not yet signed (F2)" do
    internship_agreement = create(:mono_internship_agreement, :signed_by_school_manager_only)
    employer = internship_agreement.employer

    refute internship_agreement.signed_by_employer?,
           "precondition: l'employeur ne doit pas encore avoir signé"
    assert internship_agreement.roles_not_signed_yet.include?("employer"),
           "precondition: la signature employeur doit manquer"

    assert_difference "MailActionItem.count", 2 do
      internship_agreement.sign!
    end

    action_names = internship_agreement.mail_action_items.pluck(:action_name)
    assert_includes action_names, "agreement_to_sign"
    assert_includes action_names, "agreement_signed_by_another"

    to_sign = internship_agreement.mail_action_items.find_by!(action_name: "agreement_to_sign")
    assert_equal "pending_internship_agreement", to_sign.action_type
    assert_equal "medium", to_sign.urgency_level
    assert_equal employer, to_sign.recipient
    assert_nil to_sign.resolved_at

    signed_by_another = internship_agreement.mail_action_items.find_by!(action_name: "agreement_signed_by_another")
    assert_equal "pending_internship_agreement", signed_by_another.action_type
    assert_equal "low", signed_by_another.urgency_level
    assert_equal employer, signed_by_another.recipient
    assert_nil signed_by_another.resolved_at
  end

  test "#notify_employer_agreement_signed_by_all creates a MailActionItem for the employer when agreement is signed by all" do
    internship_agreement = create(:mono_internship_agreement, aasm_state: :signatures_started)
    employer = internship_agreement.employer

    create(:signature, :school_manager, internship_agreement_id: internship_agreement.id,
           user_id: internship_agreement.school_manager.id)
    create(:signature, :student, internship_agreement_id: internship_agreement.id,
           user_id: internship_agreement.student.id)
    create(:signature, :student_legal_representative, internship_agreement_id: internship_agreement.id,
           user_id: internship_agreement.student.id)
    create(:signature, :employer, internship_agreement_id: internship_agreement.id,
           user_id: employer.id)

    assert_difference "MailActionItem.count", 2 do
      # one for the school_manager, one for the employer
      internship_agreement.sign!
    end

    item = MailActionItem.last(2).first
    assert_equal "agreement_signed_by_all", item.action_name
    assert_equal "pending_internship_agreement", item.action_type
    assert_equal employer, item.recipient
    assert_equal internship_agreement.id, item.internship_agreement_id
    assert_equal "medium", item.urgency_level
    assert_equal 1, item.max_deliveries_count
    assert item.stale_at > Time.current
    item = MailActionItem.last(2).last
    assert_equal "agreement_signed_by_all", item.action_name
    assert_equal "pending_internship_agreement", item.action_type
    assert_equal internship_agreement.student.school.management_representative, item.recipient
    assert_equal internship_agreement.id, item.internship_agreement_id
    assert_equal "medium", item.urgency_level
    assert_equal 1, item.max_deliveries_count
    assert item.stale_at > Time.current
  end

  test "#finalize creates a signatures_enabled MailActionItem for the employer" do
    internship_agreement = create(:mono_internship_agreement,
                                  aasm_state: :completed_by_employer,
                                  skip_notifications_when_system_creation: false)
    employer = internship_agreement.employer

    assert_difference -> {
      internship_agreement.mail_action_items.where(action_name: "signatures_enabled").count
    }, 1 do
      internship_agreement.finalize!
    end

    item = internship_agreement.mail_action_items.find_by!(action_name: "signatures_enabled")
    assert_equal "pending_internship_agreement", item.action_type
    assert_equal "medium", item.urgency_level
    assert_equal employer, item.recipient
  end

  test "#finalize does not notify when skip_notifications_when_system_creation is true" do
    internship_agreement = create(:mono_internship_agreement,
                                  aasm_state: :completed_by_employer,
                                  skip_notifications_when_system_creation: true)

    assert_no_difference -> { MailActionItem.where(action_name: "signatures_enabled").count } do
      internship_agreement.finalize!
    end
  end
end
