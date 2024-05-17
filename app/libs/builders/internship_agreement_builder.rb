# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipAgreementBuilder < BuilderBase

    def new_from_application(internship_application)
      authorize :new, InternshipAgreement
      internship_agreement = InternshipAgreement.new(
        {}.merge(preprocess_student_to_params(internship_application.student))
          .merge(preprocess_internship_offer_params(internship_application.internship_offer))
          .merge(preprocess_internship_application_params(internship_application))
      )
      internship_agreement.internship_application = internship_application
      internship_agreement
    end

    def create(params:)
      yield callback if block_given?
      internship_agreement = InternshipAgreement.new(
        {}.merge(preprocess_terms)
          .merge(sanitize(params))
      )
      authorize :create, internship_agreement
      internship_agreement.save!
      callback.on_success.try(:call, internship_agreement)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    def update(instance:, params:)
      yield callback if block_given?
      authorize :update, instance
      instance.attributes = {}.merge(preprocess_terms(check_soft_saving(params)))
                              .merge(sanitize(params))
      instance.save!
      callback.on_success.try(:call, instance)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    private

    attr_reader :user, :ability, :callback

    def initialize(user:)
      @user = user
      @ability = Ability.new(user)
      @callback = Callback.new
    end

    def preprocess_terms(soft_saving= false)
      return { enforce_school_manager_validations: !soft_saving } if user.school_manager? || user.admin_officer?
      return { enforce_main_teacher_validations: !soft_saving } if user.main_teacher?
      return { enforce_employer_validations: !soft_saving } if user.employer_like?
      return { skip_validations_for_system: true } if user.is_a?(Users::God)
      raise ArgumentError, "#{user.type} can not create agreement yet"
    end

    def preprocess_internship_application_params(internship_application)
      {
        date_range: "Du #{internship_application.internship_offer.first_date.strftime( "%d/%m/%Y")} au #{internship_application.internship_offer.last_date.strftime( "%d/%m/%Y")}",
        student_legal_representative_email: internship_application.student.legal_representative_email,
        student_legal_representative_phone: internship_application.student.legal_representative_phone,
        student_legal_representative_full_name: internship_application.student.legal_representative_full_name,
        student_address: internship_application.student_address
      }
    end

    def preprocess_internship_offer_params(internship_offer)
      {
        organisation_representative_full_name: internship_offer.employer.presenter.full_name,
        organisation_representative_role: internship_offer.employer.employer_role,
        siret: internship_offer.try(:siret),
        tutor_full_name: internship_offer.tutor_name,
        tutor_role: internship_offer.try(:tutor_role),
        tutor_email: internship_offer.try(:tutor_email),
        activity_preparation_rich_text: internship_offer.description_rich_text.body,
        daily_hours: internship_offer.daily_hours,
        weekly_hours: internship_offer.weekly_hours,
        lunch_break: internship_offer.lunch_break,
        weekly_lunch_break: internship_offer&.weekly_lunch_break,
        employer_name: internship_offer.employer_name,
        employer_contact_email: internship_offer.employer.email,
        internship_address: "#{internship_offer.street}, #{internship_offer.zipcode} #{internship_offer.city}"
      }
    end

    def preprocess_student_to_params(student)
      main_teacher = student&.class_room&.main_teacher
      school_manager = student.school_manager
      if student.class_room
        main_teacher_full_name = main_teacher&.name
        student_class_room = student&.class_room&.name
      else
        main_teacher_full_name = 'N/A'
        student_class_room = ""
      end
      {
        student_school: student.presenter.formal_school_name,
        school_representative_full_name: school_manager&.presenter&.full_name,
        school_representative_phone:User.sanitize_mobile_phone_number(school_manager.try(:phone), "+330") ,
        school_representative_role: "Chef d'établissement",
        school_representative_email: school_manager&.email,
        student_refering_teacher_full_name: main_teacher&.presenter&.full_name,
        student_refering_teacher_email: main_teacher&.email,
        student_refering_teacher_phone: User.sanitize_mobile_phone_number(main_teacher&.phone, "+330"),
        student_phone:  User.sanitize_mobile_phone_number(student.phone, "+330"),
        student_full_name: student.name,
        student_class_room: student_class_room,
        main_teacher_full_name: main_teacher_full_name,
        legal_status: student.school.legal_status
      }
      # student_class_room is not used ...
    end

    def check_soft_saving(params)
      params[:employer_event] == 'start_by_employer' ||
        params[:school_manager_event] == 'start_by_school_manager'
    end

    def sanitize(params)
      params.delete(:employer_event)
      params.delete(:school_manager_event)
      params
    end
  end
end
