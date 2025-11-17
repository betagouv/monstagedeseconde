class DocApiCacheMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'].start_with?('/doc_api')
      status, headers, response = @app.call(env)
      
      # Add no-cache headers for doc_api paths
      headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
      headers['Pragma'] = 'no-cache'
      headers['Expires'] = '0'
      
      [status, headers, response]
    else
      @app.call(env)
    end
  end
end
Rails.application.config.middleware.use DocApiCacheMiddleware
