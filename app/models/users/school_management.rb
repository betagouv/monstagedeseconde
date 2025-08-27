# frozen_string_literal: true

module Users
  # involve all adults in school. each are 'roled'
  #   school_manager (first registered, validated due to ac-xxx.fr email)
  #   teacher (any teacher can check & help students [they can choose class_room])
  #   other (involve psychologists, teacher assistants etc...)
  class SchoolManagement < User
    before_save :skip_confirmation!
    after_create :create_school_profiles

    include SchoolManagementAdmin
    include Signatorable
    include UserWithSchool
    include SchoolSwitchable

    validates :first_name,
              :last_name,
              :role,
              presence: true

    validates_inclusion_of :accept_terms, in: ['1', true],
                                          message: :accept_terms,
                                          on: :create

    belongs_to :class_room, optional: true
    has_many :students, through: :school
    has_many :teachers, through: :school
    has_many :invitations, class_name: 'Invitation', foreign_key: 'user_id', inverse_of: :author
    has_many :internship_applications, through: :students
    has_many :internship_agreements, through: :internship_applications

    validates :school, presence: true, on: :create
    # validate :official_uai_email_address, on: :create, if: :school_manager?
    # validate :official_email_address, on: :create

    delegate :code_uai, to: :school, prefix: true, allow_nil: true

    def custom_dashboard_path
      return url_helpers.dashboard_school_path(current_school) if school.present?

      url_helpers.account_path
    end

    def custom_candidatures_path(parameters: {})
      url_helpers.root_path
    end

    def custom_dashboard_paths
      # TODO: fix this : url_helpers.dashboard_school_class_rooms_path(school)
      array = school.present? ? [url_helpers.root_path] : []
      array << after_sign_in_path
      array
    rescue ActionController::UrlGenerationError
      []
    end

    # class_room testing induce role
    def induced_teacher?
      class_room.present?
    end

    def dashboard_name
      return 'Ma classe' if school.present? && induced_teacher?
      return 'Mon établissement' if school.present?

      ''
    end

    def custom_agreements_path
      url_helpers.dashboard_internship_agreements_path
    end

    def role_presenter
      Presenters::UserManagementRole.new(user: self)
    end
    alias presenter role_presenter

    def signatory_role
      Signature.signatory_roles[:school_manager] if role == 'school_manager'
      Signature.signatory_roles[:cpe] if role == 'cpe'
      Signature.signatory_roles[:other] if role == 'other'
      Signature.signatory_roles[:admin_officer] if role == 'admin_officer'
      Signature.signatory_roles[:teacher] if role == 'teacher'
    end

    def school_management? = true
    def school_manager? = role == 'school_manager'
    def admin_officer? = role == 'admin_officer'
    def cpe? = role == 'cpe'
    def teacher? = role == 'teacher'

    def school_manager
      try(:school).try(:school_manager)
    end

    def valid_academy_email_address?
      return false if school.blank?

      if school_caen_or_normandie?
        email =~ /\A[^@\s]+@ac-caen\.fr\z/ ||
          email =~ /\A[^@\s]+@ac-normandie\.fr\z/
      else
        email =~ /\A[^@\s]+@#{school.email_domain_name}\z/
      end
    end

    def internship_agreements_query
      internship_agreements.kept
                           .filtering_discarded_students
    end

    def pending_agreements_actions_count
      part1 = internship_agreements_query.where(aasm_state: %i[completed_by_employer started_by_school_manager])
      part2 = internship_agreements_query.signatures_started
                                         .joins(:signatures)
                                         .where.not(signatures: { signatory_role: :school_manager })
      [part1, part2].compact.map(&:count).sum
    end
    alias team_pending_agreements_actions_count pending_agreements_actions_count

    def anonymize(send_email: false)
      super(send_email:)

      update_columns(fim_user_info: nil)
    end

    private

    def create_school_profiles
      return unless school_manager? && school.present?

      # Créer l'association avec l'établissement actuel si elle n'existe pas
      UserSchool.create!(user: self, school: school) unless UserSchool.exists?(user: self, school: school)

      # Pour les school_managers, créer des associations avec les établissements liés
      nil unless school_manager?
      # Ici, vous pouvez ajouter la logique pour trouver les écoles liées
      # Par exemple, via une table de relations entre écoles ou un service externe
      # Pour l'instant, nous ne créons que l'association avec l'école actuelle
    end

    # validators
    def official_email_address
      return if school_id.blank?

      return if valid_academy_email_address?

      errors.add(
        :email,
        "L'adresse email utilisée doit être officielle.<br>ex: XXXX@ac-academie.fr".html_safe
      )
    end

    def official_uai_email_address
      return if school_id.blank?

      return if official_uai_email_address?

      message = "L'adresse email utilisée doit être l'adresse officielle " \
                "de l'établissement.<br>ex: ce.MON_CODE_UAI@ac-MON_ACADEMIE.fr"
      errors.add(:email, message.html_safe)
    end

    # notify
    def notifiable?
      school_id_changed? && school_id? && !school_manager?
    end

    def official_uai_email_address?
      if school_caen_or_normandie?
        !!(email =~ /\Ace\.\d{7}\S?@ac-caen\.fr\z/) || !!(email =~ /\Ace\.\d{7}\S?@ac-normandie\.fr\z/)
      else
        !!(email =~ /\Ace\.\d{7}\S?@#{school.email_domain_name}\z/)
      end
    end

    def school_caen_or_normandie?
      school.zipcode[0..1] == '61'
    end
  end
end
