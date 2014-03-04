require 'pathname'

module LinkedDevelopmentPmd
  class TemporarilyUnavailableWhenCrawling
    def initialize app
      @app = app
      @whitelisted_routes = [/\/assets*/, /^\/$/, /^\/docs\/*/, /^\/data$/,
                             /^\/data\/[a-z,0-9]+$/, /^\/linked-develpment-api\/*/,
                             /^\/docs$/, /^\/sparql$/, /^\/themes$/]
    end

    def call env
      if self.class.update_in_progress?
        if whitelisted? env['PATH_INFO']
          @app.call(env)
        else
          msg = "The service is temporarily offline due to a data update, please try again in a few minutes."
          response_body = ''
          content_type = 'text/plain'
          if wants_json? env
            content_type = 'application/json'
            response_body += "{\"error\":\"#{msg}\"}"
          elsif wants_html? env
            content_type = 'text/html'
            response_body += "<html><body><h1>Service Temporarily Unavailable</h1><h3>#{msg}</h3></body></html>"
          elsif wants_xml? env
            content_type = 'application/xml'
            response_body += "<hash><error>#{msg}</error></hash>"
          end

          [503, {'Content-Type' => content_type}, [response_body]]
        end
      else
        @app.call(env)
      end
    end

    def self.update_in_progress?
      Pathname.new('/tmp/cabi-crawl-in-progress').exist?
    end

    def wants_json? env
      accept_header = env['HTTP_ACCEPT']
      path = env['PATH_INFO']
      accept_header.include?('application/json') || path =~ /\.json$/
    end

    def wants_html? env
      accept_header = env['HTTP_ACCEPT']
      path = env['PATH_INFO']
      accept_header.include?('text/html') && !(path =~ /\.xml$/)
    end

    def wants_xml? env
      accept_header = env['HTTP_ACCEPT']
      path = env['PATH_INFO']
      accept_header.include?('application/xml') || path =~ /\.xml$/
    end

    def whitelisted? path
      @whitelisted_routes.any? { |regex| regex =~ path }
    end
  end
end
