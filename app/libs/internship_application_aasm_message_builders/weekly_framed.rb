# frozen_string_literal: true

module InternshipApplicationAasmMessageBuilders
  class WeeklyFramed < InternshipApplicationAasmMessageBuilder
    # for html formatted default message
    delegate :student,
             :internship_offer,
             to: :internship_application

    private

    def on_approved_message
      <<~HTML.strip
        <p>Bonjour #{student.presenter.formal_name},</p>
        <p>Votre candidature pour le stage "#{internship_offer.title}" est acceptée .</p>
        <p>Vous devez maintenant faire signer la convention de stage.</p>
      HTML
    end

    def on_canceled_by_employer_message
      <<~HTML.strip
        <p>Bonjour #{student.presenter.formal_name},</p>
        <p>Votre candidature pour le stage "#{internship_offer.title}" est annulée .</p>
      HTML
    end

    def on_canceled_by_student_message
      ''
    end
    alias on_rejected_message on_canceled_by_student_message
  end
end
