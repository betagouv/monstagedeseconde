# frozen_string_literal: true

module InternshipApplicationsHelper
  def is_resume_empty?(internship_application)
    !has_resume_other?(internship_application) &&
      !has_resume_languages?(internship_application)
  end

  def has_resume_other?(internship_application)
    internship_application.student
                          .resume_other
                          .present?
  end

  def has_resume_languages?(internship_application)
    internship_application.student
                          .resume_languages
                          .present?
  end

  def sign_application_modal_id(internship_application)
    "sign-internship-application-#{internship_application.id}-#{internship_application.user_id}"
  end

  def show_application_modal_id(internship_application)
    "show-internship-application-#{internship_application.id}-#{internship_application.user_id}"
  end

  def callout_title(internship_application)
    if internship_application.is_re_approvable?
      'Vous souhaitez retenir cette candidature ?'
    else
      'Vous ne souhaitez plus retenir cette candidature ?'
    end
  end

  def callout_text(internship_application)
    "Un email sera envoyé à l’élève lui indiquant que vous souhaitez \
    #{internship_application.is_re_approvable? ? 'retenir' : 'refuser'} \
    sa candidature."
    + " Il devra ensuite confirmer sa participation au stage." if internship_application.is_re_approvable?
  end

  def callout_btn_title(internship_application)
    (internship_application.is_re_approvable? ? "Retenir" : "Refuser" ) + " cette candidature"
  end
end
