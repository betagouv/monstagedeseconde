module Services::EmployerActions
  class EmployerDigestMailer < ::Services::CommonActions::BaseDigestMailer
    def self.resolver_class = Resolver
    def self.mailer_class = EmployerActionsMailer
    def self.digest_email_method = :employer_digest_email

    def self.deliver(mail)
      Rails.env.review? && mail.deliver_now || mail.deliver_later
    end
  end
end
