module Services::StudentActions
  class StudentDigestMailer < ::Services::CommonActions::BaseDigestMailer
    def self.resolver_class = Resolver
    def self.mailer_class = StudentActionsMailer
    def self.digest_email_method = :student_digest_email
  end
end
