# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def anonymize_user(recipient_email:)
    mail(to: recipient_email, subject: 'Confirmation - suppression de votre compte')
  end

  def missing_school_manager_warning_email(offer:, student:)
    school = student.school
    return if school.nil?

    @student_prez = student.presenter
    @offer_prez = offer.presenter
    @school_manager_email = made_school_manager_email(school)
    @url = rails_pathes.new_user_registration_url(
      host: ENV['HOST'],
      as: 'SchoolManagement',
      email: @school_manager_email,
      user_role: 'school_manager'
    )
    send_email(
      to: @school_manager_email,
      subject: 'Une convention de stage vous attend.'
    )
  end

  def export_offers(user, params)
    recipient_email = user.email
    if user.ministry_statistician?
      params.merge!(ministries: user.ministries.map(&:id))
    else
      params.delete(:ministries)
    end

    offers = Finders::ReportingInternshipOffer.new(params:).dimension_offer

    attachment_name = "#{serialize_params_for_filenaming(params)}.xlsx"
    xlsx = render_to_string layout: false,
                            handlers: [:axlsx],
                            formats: [:xlsx],
                            template: 'reporting/internship_offers/index_offers',
                            locals: { offers: offers,
                                      presenter_for_dimension: Presenters::Reporting::DimensionByOffer }
    attachments[attachment_name] = { mime_type: Mime[:xlsx], content: xlsx }
    mail(to: recipient_email, subject: 'Export des offres de 1élève1stage')
  end

  private

  def rails_pathes
    Rails.application.routes.url_helpers
  end

  def serialize_params_for_filenaming(params)
    params.compact.inject('export-des-offres') do |accu, (k, v)|
      "#{accu}-#{InternshipOffer.human_attribute_name(k.to_s).parameterize}-#{v.to_s.parameterize}"
    end
  end

  def made_school_manager_email(school)
    "ce.#{school.code_uai.downcase}@#{school.email_domain_name}"
  end
end
