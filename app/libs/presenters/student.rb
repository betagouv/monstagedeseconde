module Presenters
  class Student < User
    delegate :school, to: :user
    def name
      return anonymized_message if student.anonymized?

      student.name
    end

    def school_name
      return anonymized_message if student.anonymized?

      school.try(:name)
    end

    def formal_school_name
      return '' unless school

      "#{school.name} à #{school.city} (Code U.A.I: #{school.code_uai})"
    end

    def school_city
      return anonymized_message if student.anonymized?

      school.try(:city)
    end

    def age
      return anonymized_message if student.anonymized?

      "#{student.age} ans"
    end

    def email
      return student.email_domain_name if student.anonymized?

      student.email
    end

    def phone
      return anonymized_message if student.anonymized?

      student.phone
    end

    def birth_date
      return anonymized_message if student.anonymized?

      student.birth_date.strftime('%d/%m/%Y')
    end

    def student
      user
    end

    def sing_feminine(word)
      return "#{word}e" if user.gender == 'f'

      word
    end

    def dashboard_name_link
      url_helpers.dashboard_students_internship_applications_path(student_id: user.id)
    end

    def validated_by_employer_applications_count
      student.internship_applications.validated_by_employer.count
    end

    def forbidden_application_reason(internship_offer)
      if student.internship_applications.exists?(internship_offer_id: internship_offer.id)
        return 'Vous avez déjà postulé à cette offre'
      end
      return 'Offre incompatible avec votre classe' unless student.grade.id.in?(internship_offer.grades.ids)

      if student.with_2_weeks_internships_approved?
        'Vous avez déjà validé un stage pour les deux semaines'
      else
        'Stage déjà validé sur cette semaine'
      end
    end

    private

    def anonymized_message
      'Non communiqué (Donnée anonymisée)'
    end
  end
end
