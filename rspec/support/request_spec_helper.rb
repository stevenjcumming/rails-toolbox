# spec/support/request_spec_helper.rb
module RequestSpecHelper
  def json
    JSON.parse(response.body)
  end

  def errors
    json["errors"]
  end

  def valid_headers
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type"  => "application/json"
    }
  end

  def invalid_headers
    {
      "Authorization" => nil,
      "Content-Type"  => "application/json"
    }
  end

  def token(payload)
    JWT.encode({ user_id: @user.id }, jwt_key, "HS256")
  end

  private 

    def jwt_key
      Rails.application.credentials.dig(:jwt_secret_key)
    end
end
