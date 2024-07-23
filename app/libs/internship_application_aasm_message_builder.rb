# frozen_string_literal: true

# wire default rich text message with internship_application rich text attributes
# * approved_message (on internship_application aasm transition approved)
# * rejected_message (on internship_application aasm transition rejected)
# * canceled_by_employer_message (on internship_application aasm transition canceled_by_employer)
# * canceled_by_student_message (on internship_application aasm transition canceled_by_student)
class InternshipApplicationAasmMessageBuilder
  # "exposed" attributes
  delegate :approved_message_tmp,
           :rejected_message_tmp,
           :canceled_by_employer_message_tmp,
           :canceled_by_student_message_tmp,
           to: :internship_application

  MAP_TARGET_TO_BUTTON_COLOR = {
    employer_validate!: '',
    approve!: '',
    cancel_by_employer!: 'fr-btn--secondary',
    cancel_by_student!: 'fr-btn--secondary',
    reject!: 'fr-btn--secondary'
  }.freeze

  def target_action_color
    MAP_TARGET_TO_BUTTON_COLOR.fetch(aasm_target)
  end

  #
  # depending on target aasm_state, user edit custom message but
  # action_text default is a bit tricky to initialize
  # so depending on the targeted state, fetch the rich_text_object (void)
  # and assign the body [which show on front end the text]
  #

  MAP_TARGET_TO_FIELD_ATTRIBUTE = {
    employer_validate!: :validated_by_employer_message_tmp,
    approve!: :approved_message_tmp,
    cancel_by_employer!: :canceled_by_employer_message_tmp,
    cancel_by_student!: :canceled_by_student_message_tmp,
    reject!: :rejected_message_tmp
  }.freeze

  def associated_text_field
    MAP_TARGET_TO_FIELD_ATTRIBUTE.fetch(aasm_target)
  end

  private

  attr_reader :aasm_target, :internship_application

  def initialize(internship_application:, aasm_target:)
    @internship_application = internship_application
    @aasm_target = aasm_target
  end
end
