# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipAgreementBuilder < BuilderBase
    # corporation: présent => stage partagé, on génère UNE convention pour CETTE
    # structure d'accueil (remplie depuis ses propres coordonnées / horaires / semaine).
    def new_from_application(internship_application, corporation: nil)
      authorize :new, InternshipAgreement
      internship_offer = internship_application.internship_offer
      multi_agreements = internship_offer.from_multi?
      params = {}.merge(preprocess_student_to_params(internship_application.student))
                 .merge(preprocess_internship_offer_params(internship_offer, corporation: corporation))
                 .merge(preprocess_internship_application_params(internship_application, corporation: corporation))
      klass = multi_agreements ? InternshipAgreements::MultiInternshipAgreement : InternshipAgreements::MonoInternshipAgreement
      internship_agreement = klass.new(**params)
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

    def preprocess_terms(soft_saving = false)
      return { enforce_school_manager_validations: !soft_saving } if user.school_management?
      return { enforce_teacher_validations: !soft_saving } if user.teacher?
      return { enforce_employer_validations: !soft_saving } if user.employer_like?
      return { skip_validations_for_system: true } if user.god?

      raise ArgumentError, "#{user.type} can not create agreement yet"
    end

    def preprocess_internship_application_params(internship_application, corporation: nil)
      date_range =
        if corporation
          date_range_for_corporation(internship_application, corporation)
        else
          Presenters::InternshipApplication.new(internship_application, user).date_range
        end
      {
        date_range: date_range,
        student_legal_representative_email: internship_application.student.legal_representative_email,
        student_legal_representative_phone: internship_application.student.legal_representative_phone,
        student_legal_representative_full_name: internship_application.student.legal_representative_full_name,
        student_address: internship_application.student_address
      }
    end

    # Stage partagé : chaque structure accueille l'élève sur 1 semaine (sa période).
    # On restreint le date_range de la convention à la semaine concernée.
    def date_range_for_corporation(internship_application, corporation)
      weeks = internship_application.weeks.sort_by(&:monday)
      week = corporation.period.to_i == 2 ? weeks.last : weeks.first
      return Presenters::InternshipApplication.new(internship_application, user).date_range if week.nil?

      "Du #{week.monday.strftime('%d/%m/%Y')} au #{week.friday.strftime('%d/%m/%Y')}"
    end

    # Horaires de la convention selon la période de la structure : période 2 utilise le
    # second jeu d'horaires s'il a été saisi, sinon retombe sur celui de la période 1.
    def hours_for_corporation(internship_offer, corporation)
      if corporation.period.to_i == 2 && period_2_specific_hours?(internship_offer)
        { daily_hours: internship_offer.daily_hours_2, weekly_hours: internship_offer.weekly_hours_2 }
      else
        { daily_hours: internship_offer.daily_hours, weekly_hours: internship_offer.weekly_hours }
      end
    end

    def period_2_specific_hours?(internship_offer)
      internship_offer.weekly_hours_2.to_a.any?(&:present?) ||
        internship_offer.daily_hours_2.to_h.values.flatten.any?(&:present?)
    end

    # Stage partagé : convention remplie depuis SA structure d'accueil (Corporation)
    # plutôt que depuis l'employeur coordinateur.
    def preprocess_corporation_params(internship_offer, corporation)
      hours = hours_for_corporation(internship_offer, corporation)
      {
        corporation_id: corporation.id,
        organisation_representative_full_name: corporation.employer_name,
        organisation_representative_role: corporation.employer_role,
        employer_name: corporation.corporation_name,
        employer_contact_email: corporation.employer_email,
        siret: corporation.siret,
        tutor_full_name: corporation.tutor_name,
        tutor_role: corporation.tutor_role_in_company,
        tutor_email: corporation.tutor_email,
        daily_hours: hours[:daily_hours],
        weekly_hours: hours[:weekly_hours],
        lunch_break: internship_offer.lunch_break,
        internship_address: corporation.internship_full_address,
        entreprise_address: corporation.corporation_address,
        activity_scope: internship_offer.description
      }
    end

    def preprocess_internship_offer_params(internship_offer, corporation: nil)
      return preprocess_corporation_params(internship_offer, corporation) if corporation

      if internship_offer.from_multi?
        {
        organisation_representative_full_name: internship_offer.employer.presenter.full_name,
        organisation_representative_role: internship_offer.employer.employer_role,
        siret: internship_offer.try(:siret),
        tutor_full_name: nil,
        tutor_role: nil,
        tutor_email: nil,
        daily_hours: internship_offer.daily_hours,
        weekly_hours: internship_offer.weekly_hours,
        lunch_break: internship_offer.lunch_break,
        employer_name: internship_offer.employer_name,
        employer_contact_email: internship_offer.employer.email,
        internship_address: "#{internship_offer.street}, #{internship_offer.zipcode} #{internship_offer.city}",
        entreprise_address: internship_offer.entreprise_full_address,
        activity_scope: internship_offer.description
        }
      else
        {
        organisation_representative_full_name: internship_offer.employer.presenter.full_name,
        organisation_representative_role: internship_offer.employer.employer_role,
        siret: internship_offer.try(:siret),
        daily_hours: internship_offer.daily_hours,
        weekly_hours: internship_offer.weekly_hours,
        lunch_break: internship_offer.lunch_break,
        employer_name: internship_offer.employer_name,
        employer_contact_email: internship_offer.employer.email,
        internship_address: "#{internship_offer.street}, #{internship_offer.zipcode} #{internship_offer.city}",
        entreprise_address: internship_offer.entreprise_full_address,
        activity_scope: internship_offer.description
       }
      end
    end

    def preprocess_student_to_params(student)
      teacher = student&.class_room&.teacher
      school_manager = student.school_manager
      student_class_room = if student.class_room
                             student&.class_room&.name
      else
                             ''
      end
      {
        student_school: student.presenter.formal_school_name,
        school_representative_full_name: school_manager&.presenter&.full_name,
        school_representative_phone: User.sanitize_mobile_phone_number(school_manager.try(:phone), '+330'),
        school_representative_role: "Chef d'établissement",
        school_representative_email: school_manager&.email,
        student_refering_teacher_full_name: teacher&.presenter&.full_name || 'N/A',
        student_refering_teacher_email: teacher&.email,
        student_refering_teacher_phone: User.sanitize_mobile_phone_number(teacher&.phone, '+330'),
        student_phone: User.sanitize_mobile_phone_number(student.phone, '+330'),
        student_full_name: student.name,
        student_class_room: student_class_room,
        student_birth_date: student.birth_date,
        legal_status: student.school.legal_status,
        delegation_date: student.school.try(:delegation_date)
      }
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
