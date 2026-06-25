module Services::SchoolManagementActions
  class SchoolManagementDigestMailer < ::Services::CommonActions::BaseDigestMailer
    def self.resolver_class = Resolver
    def self.mailer_class = SchoolManagementActionsMailer
    def self.digest_email_method = :school_management_digest_email
  end
end
