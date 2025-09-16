# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src :self, :https, "'connect-src'", "'unsafe-inline'", lambda {
      ENV.fetch('MATOMO_URL', '').gsub(%r{/js/.*}, '')
    }
    policy.connect_src :self, :https
    policy.style_src   :self, :https, "'unsafe-inline'"
    policy.frame_src   'https://plugins.crisp.chat', 'https://uneleveunstage.crisp.help', ENV['METABASE_SITE_URL']
    if Rails.env.development?
      policy.frame_src :self, 'http://localhost:3000', 'https://plugins.crisp.chat', 'https://uneleveunstage.crisp.help', ENV['METABASE_SITE_URL']
    end
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  # config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
