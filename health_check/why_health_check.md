# Why Health Check?

You may need to have a "health check" route for auto scaling, load balancing, or uptime monitoring. For this we need some middleware, and we are going to insert it before the Rails logger because I don't want it in the logs, but you could use `insert_after` if you want to see the logs

Note: Rails 7.1 introduced "Rails::HealthController#show" and maps it to /up for newly generated applications.

```ruby
# lib/middleware/health_check.rb
class HealthCheck

  SUCCESS_RESPONSE = [ 200, { 'Content-Type' => 'text/plain' }, [ 'Success!'.freeze ] ]
  PATH = '/health'.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'.freeze] == PATH
      return SUCCESS_RESPONSE
    else
      @app.call(env)
    end
  end

end
```

```ruby
# Add the middleware
# config/application.rb

require_relative '../lib/middleware/health_check'

# omit

config.middleware.insert_before Rails::Rack::Logger, HealthCheck

```
