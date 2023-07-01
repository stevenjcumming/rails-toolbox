# Internal Server Errors

In production, we need a way to handle internal server errors (5xx). Hopefully, they don't show up at all, but if they do, we want to render the same format as 4xx errors.

To test this, we can set `config.consider_all_requests_local = false` in `development.rb`

```ruby
# lib/internal_error_handler.rb
# We want to log the error (or send it to sentry), but not render it
class InternalErrorHandler
  def call(env)
    exception = env['action_dispatch.exception']
    status = exception.try(:status) || 500
    message = exception.message || 'Unknown error'
    Rails.logger.error("#{status}: #{message}")

    [500, headers, [body]]
  end

  private

    def headers
      {
        'Content-Type' => 'application/json',
        'Content-Length' => body.length.to_s
      }
    end

    def body
      {
        error: {
          code: "internal_server_error",
          message: message,
          tracking_id: SecureRandom.uuid,
          attribute: nil,
          validation: nil
        }
      }.to_json
    end

    def message
      I18n.t(
        :internal_error,
        scope: [:api, :errors, :messages],
        default: "Internal Server Error"
      )
    end
end
```

```ruby
# config/application.rb
config.exceptions_app = ->(env) { InternalErrorHandler.new.call(env) }
```
