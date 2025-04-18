module InternshipAgreements
  class ButtonComponent < BaseComponent
    attr_reader :internship_agreement, :current_user, :label, :second_label

    def initialize(internship_agreement:,
                   current_user:,
                   label: {status: 'enabled', text: 'Editer'},
                   second_label: {status: 'disabled', text: 'En attente'})
      @internship_agreement = internship_agreement
      @current_user         = current_user
      @label              ||= button_label(user: current_user)
      @second_label       ||= second_button_label
    end

    def started_or_signed?
      after_validation_states = %w[validated
                                   signatures_started
                                   signed_by_all
                                   signed]
      state_in?(after_validation_states) ||
        (current_user.employer_like? && right_after_employer_filled_agreement_state?)
    end

    def on_going_process?
      current_user.employer_like? || right_after_employer_filled_agreement_state?
    end

    def right_after_employer_filled_agreement_state?
      state_in?(%w[completed_by_employer started_by_school_manager])
    end

    def state_in?(states)
      internship_agreement.aasm_state.in?(states)
    end

    def button_label(user:)
      if user.employer_like?
        case @internship_agreement.aasm_state
        when 'draft' then
          {status: 'cta', text: 'Remplir ma convention'}
        when 'started_by_employer' then
          {status: 'cta', text: 'Valider ma convention'}
        when 'completed_by_employer', 'started_by_school_manager', 'validated', 'signatures_started', 'signed_by_all' then
          {status: 'secondary_cta', text: 'Imprimer'}
        end
      else # school_manager
        case @internship_agreement.aasm_state
        when 'draft', 'started_by_employer' then
          {status: 'disabled', text: 'En attente'}
        when 'completed_by_employer' then
          {status: 'cta', text: 'Remplir ma convention'}
        when 'started_by_school_manager' then
          {status: 'cta', text: 'Valider ma convention'}
        when 'validated', 'signatures_started', 'signed_by_all' then
          {status: 'secondary_cta', text: 'Imprimer'}
        end
      end
    end

    def second_button_label
      case @internship_agreement.aasm_state
      when 'draft', 'started_by_employer' ,'completed_by_employer', 'started_by_school_manager' then
        {status: 'hidden', text: ''}
      when 'validated', 'signatures_started' then
        if user_signed_condition?
          {status: 'disabled', text: 'Déjà signée'}
        elsif current_user.can_sign?(@internship_agreement)
          {status: 'enabled', text: 'Ajouter aux signatures'}
        else
          {status: 'hidden', text: ''}
        end
      when 'signed_by_all' then {status: 'disabled', text: 'Signée de tous'}
      end
    end

    def user_signed_condition?
      if current_user.role.in?(Signature::SCHOOL_MANAGEMENT_SIGNATORY_ROLE)
        @internship_agreement.signed_by_school_management?
      elsif current_user.employer_like?
        @internship_agreement.signed_by_team_member?(user: current_user)
      else
        false
      end
    end
  end
end
