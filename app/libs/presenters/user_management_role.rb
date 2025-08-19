module Presenters
  class UserManagementRole < User
    TYPE_TRANSLATOR = {
      'Users::Student': 'Elève',
      'Users::Employer': 'Offreur',
      'Users::God': 'Administrateur',
      'Users::Operator': 'Operateur',
      'Users::PrefectureStatistician': 'Référent départemental',
      'Users::MinistryStatistician': 'Référent central',
      'Users::EducationStatistician': 'Référent éduc. nat.',
      'Users::AcademyStatistician': 'Référent académique',
      'Users::AcademyRegionStatistician': 'Référent académique régional'
    }
    ROLE_TRANSLATOR = {
      school_manager: "Chef d'établissement",
      teacher: 'Professeur',
      other: 'Autres fonctions',
      cpe: 'CPE',
      admin_officer: 'Responsable administratif'
    }

    def role
      case user
      when Users::Student
        TYPE_TRANSLATOR['Users::Student'.to_sym]
      when Users::Employer
        TYPE_TRANSLATOR['Users::Employer'.to_sym]
      when Users::God
        TYPE_TRANSLATOR['Users::God'.to_sym]
      when Users::Operator
        TYPE_TRANSLATOR['Users::Operator'.to_sym]
      when Users::PrefectureStatistician
        TYPE_TRANSLATOR['Users::PrefectureStatistician'.to_sym]
      when Users::MinistryStatistician
        TYPE_TRANSLATOR['Users::MinistryStatistician'.to_sym]
      when Users::EducationStatistician
        TYPE_TRANSLATOR['Users::EducationStatistician'.to_sym]
      when Users::AcademyStatistician
        TYPE_TRANSLATOR['Users::AcademyStatistician'.to_sym]
      when Users::AcademyRegionStatistician
        TYPE_TRANSLATOR['Users::AcademyRegionStatistician'.to_sym]
      when Users::SchoolManagement
        case user.role.to_sym
        when :school_manager
          ROLE_TRANSLATOR[:school_manager]
        when :teacher
          ROLE_TRANSLATOR[:teacher]
        when :other
          ROLE_TRANSLATOR[:other]
        when :cpe
          ROLE_TRANSLATOR[:cpe]
        when :admin_officer
          ROLE_TRANSLATOR[:admin_officer]
        else
          'Utilisateur'
        end
      when Users::Visitor
        'Visiteur'
      else
        'Utilisateur'
      end
    end

    def self.human_types_and_roles(key)
      if TYPE_TRANSLATOR.has_key?(key)
        TYPE_TRANSLATOR[key]
      elsif ROLE_TRANSLATOR.has_key?(key)
        ROLE_TRANSLATOR[key]
      else
        'Erreur'
      end
    end

    def dashboard_name_link
      if user.school &&
         user.class_room &&
         user.role == 'teacher'
        return url_helpers.dashboard_school_class_room_students_path(school_id: user.school.id, class_room_id: user.class_room.id)
      elsif user.school
        return url_helpers.dashboard_school_path(user.school)
      end
      url_helpers.root_path
    end

    private

    attr_reader :user
    def initialize(user:)
      @user = user
    end
  end
end
