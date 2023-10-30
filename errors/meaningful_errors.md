# Meaningful Errors

Ruby on Rails provides excellent messages for validation errors:

```ruby
class Person
  validates_presence_of :name, :address, :email
  validates_length_of :name, in: 5..30
end

person = Person.create(address: '123 First St.')
person.errors.full_messages
# => ["Name is too short (minimum is 5 characters)", "Name can't be blank", "Email can't be blank"]
```

But we can add more details to level up the API for public or private consumption. Extending `ActiveModel::Errors#as_json` will allow us to use messages based on codes (and language). It will also allow use custom attributes and validation if desired.

The goal is to make something like this:

```json
{
  "errors": [
    {
      "code": "person_failed",
      "message": "Name is too short (minimum is 5 characters)",
      "tracking_id": "243b9461-70dc-4028-b1e3-f4ed8d861b4e",
      "attribute": "name",
      "validation": "too_short"
    }
  ]
}
```

```json
{
  "errors": [
    {
      "code": "refund_purchase_expired",
      "message": "Refundability has expired.",
      "tracking_id": "243b9461-70dc-4028-b1e3-f4ed8d861b4e",
      "attribute": "refundability",
      "validation": "past_expiration"
    }
  ]
}
```

## Steps

#### 1. Extend ActiveModel::Errors

```ruby
# lib/core_ext/errors.rb
module ActiveModel
  class Errors

    attr_reader :base

    def as_json(options = nil)
      errors.map do |error|
        # override base if record is present
        base = error.options[:record] if error.options[:record].present?
        ErrorSerializer.new(base, error).serialize
      end
    end
  end

  class ErrorSerializer

    attr_reader :record, :error

    def initialize(record, error)
      @record = record
      @error = error
    end

    def serialize
      {
        code: code,
        message: message,
        tracking_id: SecureRandom.uuid,
        attribute: attribute,
        validation: validation
      }
    end

    private

      def code
        error.options[:code] || "#{underscored_resource_name}_invalid"
      end

      def message
        I18n.t(
          code,
          scope: [:api, :errors, :messages],
          default: error.full_message
        )
      end

      def attribute
        error.options[:attribute] || error.attribute || "#{underscored_resource_name}"
      end

      def validation
        error.options[:validation] || error.type
      end

      def underscored_resource_name
        if @record
          @record.class.to_s.titleize.gsub(/\W/, '_').underscore
        else
          error.options[:attribute] || error.attribute
        end
      end

  end

end
```

#### Replacing errors at the controller level

Some errors don't belong on a model, but we want to keep the errors consistent so we create new errors and override `as_json`

Validation is `nil`, because we can use that to differentiate these errors from model errors.

Examples: login error, unauthorized access, record not found, etc

```ruby
# app/errors/login_credentials_error.rb
class LoginCredentialsError < StandardError

  def as_json(_options=nil)
    {
      code:        :login_credentials_invalid,
      message:     message,
      tracking_id: SecureRandom.uuid,
      attribute:   nil,
      validation:  nil
    }
  end

  def message
    I18n.t(
      :login_credentials_invalid,
      scope:   [:api, :errors, :messages],
      default: "Login credentials invalid"
    )
  end

end

# app/errors/unauthorized_error.rb
class UnauthorizedError < StandardError

  def as_json(_options=nil)
    {
      code:        :not_authorized,
      message:     message,
      tracking_id: SecureRandom.uuid,
      attribute:   nil,
      validation:  nil
    }
  end

  def message
    I18n.t(
      :not_authorized,
      scope:   [:api, :errors, :messages],
      default: "Not authorized"
    )
  end

end
```

#### 2. Add the error messages for our codes

We will utilize I18n so we can even use messages in other languages. You could extend this further with `attribute` and `validation`

```yaml
en:
  api:
    errors:
      messages:
        custom_error_code: "This is a custom error message"
        login_credentials_invalid: "Login credentials are invalid."
        record_not_found: "Record could not be found."
        not_authorized: "Not authorized to perform action."
```

#### 3. Implementation

Setting errors

```ruby
# Any ActiveModel class
# if you are new to ruby3 read this: https://github.com/rails/rails/issues/41270
errors.add(:model_attribute, **{ code: :custom_error_code })
errors.add(:base, **{ code: :custom_error_code, validation: "custom_validation" })
```

Rendering errors

```ruby
# Controllers
render json: { errors: [UnauthorizedError.new] }, status: :unauthorized
render json: { errors: example.errors }, status: :bad_request
render json: { errors: example_form.errors }, status: :bad_request
```
