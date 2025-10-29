# frozen_string_literal: true

module Presenters
  class User
    delegate :application, to: Rails
    delegate :routes, to: :application
    delegate :url_helpers, to: :routes
    delegate :internship_offers_path, to: :url_helpers
    delegate :default_search_options, to: :user
    delegate :email, to: :user

    def forbidden_application_reason(internship_offer) ; nil end

    def initials
      "#{user.first_name[0].capitalize}.#{user.last_name[0].capitalize}."
    end

    def short_name
      "#{user.first_name[0].capitalize}.#{user.last_name}"
    end

    def full_name
      "#{user.first_name.capitalize} #{user.last_name.capitalize}"
    end

    def formal_name
      "#{gender_text} #{user.first_name.try(:capitalize)} #{user.last_name.try(:capitalize)}".strip
    end

    def full_name_camel_case
      "#{user.first_name} #{user.last_name}".upcase.gsub(' ', '_')
    end

    def civil_name
      name = user.last_name.downcase.capitalize
      "#{gender_text} #{name}".strip
    end

    def short_civil_full_name
      name = full_name
      case user.gender
      when 'm'
        "M. #{name}"
      when 'f'
        "Mme #{name}"
      else
        name
      end
    end

    def gender_text
      return 'Madame' if user.gender.eql?('f')
      return 'Monsieur' if user.gender.eql?('m')

      ''
    end

    def role_name
      UserManagementRole.new(user: user).role
    end

    def default_internship_offers_path
      return internship_offers_path if user.nil?
      return internship_offers_path unless user.respond_to?(:school)
      return internship_offers_path if user.school.nil?

      internship_offers_path(default_search_options)
    end

    def dashboard_name_link
      url_helpers.root_path
    end

    def show_when_subscribe?(as: , field:)
      field.in?(subscribe_fields(as: as))
    end

    def subscription_incipit(as:)
      title = "Inscription"
      subtitle = ""

      case as
      when "Student"
        title = "Se créer un compte en tant qu'élève"
      when "Employer"
        title = "Se créer un compte en tant qu'offreur"
        subtitle = "Déposez " \
        "vos offres de stages à l'aide de votre compte personnalisé. " \
        "Il vous permettra à tout moment de modifier vos offres et de " \
        "suivre leur avancement."
      when "PrefectureStatistician"
        title = "Se créer un compte en tant que référent départemental"
        subtitle = "Vous êtes " \
        "référent départemental et souhaitez accéder aux " \
        "statistiques relatives aux offres de stage de votre département."
      when "MinistryStatistician"
        title = "Se créer un compte en tant que référent d'administration centrale"
        subtitle = "Vous êtes référent d'administration centrale et " \
        "souhaitez accéder aux statistiques relatives aux offres de stage " \
        "de votre administration."
      when "EducationStatistician"
        title = "Se créer un compte en tant que référent DSDEN"
        subtitle = "Vous êtes référent départemental du ministère " \
        "de l'éducation nationale et souhaitez accéder aux statistiques " \
        "relatives aux offres de stage de votre département."
      when 'AcademyStatistician'
        title = "Se créer un compte en tant que référent académique"
        subtitle = "Vous êtes référent académique et souhaitez accéder " \
        "aux statistiques relatives aux offres de stage de votre académie."
      when 'AcademyRegionStatistician'
        title = "Se créer un compte en tant que référent académique régional"
        subtitle = "Vous êtes référent académique régional et souhaitez " \
        "accéder aux statistiques relatives aux offres de stage de votre académie."
      when "SchoolManagement"
        title = "Se créer un compte en tant que gestionnaire d'établissement scolaire"
        subtitle = "Vous souhaitez que vos élèves trouvent un stage " \
        "de qualité. Cet outil vous permettra d'accéder à un tableau " \
        "de suivi de vos élèves tout au long de leur recherche de stage."
      end
      {
        title: title,
        subtitle: subtitle
      }
    end

    def subscribe_fields(as:)
      case as
      when "Employer"
        %i[employer_role email]
      when "SchoolManagement"
        %i[school email school_id class_room_id role ]
      when 'MinistryStatistician', 'Statistician', 'EducationStatistician', 'AcademyStatistician', 'AcademyRegionStatistician'
        %i[email]
      else
        []
      end
    end

    def pros_videos_data
      data = [
        {label: "Témoignage de Sophie Boissard de Clariane",
         url: "uL90WJEWbJk?si=qI1uI3wIcb6DPuZX"},
        {label: "Témoignage de Nathalie Fournier d'ArcelorMittal",
         url: "4yxBNMKTBZ4?si=PtQsvfQ3Cj31STs"},
        {label: "Témoignage de Carine Dellière de L'Oréal France",
         url: "KPvnLUa16Qg?si=n03OB1QZE9osKMdZ"},
        {label: "Témoignage de Jean-Sébastien Blanc d'Engie",
         url: "rzZqQHXeq0s?si=A3E6-rmNVUAIq5dS"},
        {label: "Témoignage de Chloé Martin, Directrice d'école",
         url: "f48XiJGNXJ8?si=e1lLx5lvaDRl3Tge"}
      ]
      data.each_with_index.map do |d, index|
        {
          label: d[:label],
          url: "https://www.youtube-nocookie.com/embed/#{d[:url]}&amp;controls=0",
          title: d[:label],
          id: index
        }
      end
    end

    protected

    attr_reader :user
    def initialize(user)
      @user = user
    end
  end
end
