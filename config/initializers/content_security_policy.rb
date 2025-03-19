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
      # Allow @vite/client to hot reload javascript changes in development
      if Rails.env.development?
        policy.script_src(*policy.script_src, :unsafe_eval, "http://#{ViteRuby.config.host_with_port}")
      end

      # You may need to enable this in production as well depending on your setup.
      #    policy.script_src *policy.script_src, :blob if Rails.env.test?

      ENV.fetch('MATOMO_URL', '').gsub(%r{/js/.*}, '')
    }
    policy.connect_src :self, :https
    # Allow @vite/client to hot reload changes in development
    policy.connect_src(*policy.connect_src, "ws://#{ViteRuby.config.host_with_port}") if Rails.env.development?

    policy.style_src :self, :https, "'unsafe-inline'"
    # Allow @vite/client to hot reload style changes in development
    policy.style_src(*policy.style_src, :unsafe_inline) if Rails.env.development?

    policy.frame_src 'https://plugins.crisp.chat', 'https://uneleveunstage.crisp.help', ENV['METABASE_SITE_URL']
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  # config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
