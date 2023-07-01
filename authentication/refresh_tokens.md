# Refresh Token

This page with show you how to build rotating refresh token authentication with Rails for a frontend client (React app, mobile app, etc). This authentication strategy will allow client(s) time-limited access without requiring the user to log in after a single JWT has expired. A single JWT access token is either a bad user experience (hourly expiration) or a security flaw (expiration >2 weeks).

If increased security is required you can lower the refresh tokens (or both tokens) and effectively only allow access while in use. After X minutes of inactivity the refresh token is expired which requires the user to log in again. Alternatively (or additionally), you can add additional "checks" with device fingerprinting and/or IP address comparison.

## Process Overview:

![Alt text](https://res.cloudinary.com/bahdcoder/image/upload/v1606712432/refresh-token-rotation-flow.png)
_[Source: https://katifrantz.com](https://katifrantz.com/the-ultimate-guide-to-jwt-server-side-authentication-with-refresh-tokens)_

## Required Gems

- [jwt](https://github.com/jwt/ruby-jwt)
- [bcrypt](https://github.com/bcrypt-ruby/bcrypt-ruby)

## Steps

#### 1. Create a User model

I'll skip this part because all you really need to know is you need a User with a password, I use `has_secure_password` from `bcrypt`.

#### 2. Create the access token

We want to create an access token with the user_id to authenticate requests to the API. We also want to set a short expiration time (30 minutes). You can add a generic encode method if JWTs are needed elsewhere. Make sure to set `jwt_secret_key` in your credentials file.

```ruby
# lib/json_web_token.rb
class JsonWebToken

  ALGORITHM = "HS256".freeze
  ISSUER = "https://yourwebsite.com".freeze
  EXPIRES_IN = 30.minutes.to_i.freeze

  def self.access_token(user)
    payload = access_token_payload(user)
    JWT.encode(payload, hmac_secret, ALGORITHM)
  end

  def self.decode(token)
    options = { iss: ISSUER, verify_iss: true, algorithm: ALGORITHM }
    decoded_array = JWT.decode(token, hmac_secret, true, options)
    decoded_array.first # payload
  rescue JWT::DecodeError => e
    Rails.logger.info(e.message)
    nil
  end

  def self.hmac_secret
    Rails.application.credentials.dig(:jwt_secret_key)
  end

  def self.access_token_payload(user)
    {
      user_id: user.id,
      iss:     ISSUER,
      exp:     Time.current.to_i + EXPIRES_IN
    }
  end

end
```

#### 3. Create the refresh token

Refresh token unlike access tokens are stored (hashed) in the database. This is a one way process, so like a passwords with bcrypt, we will need to hash the refresh token to compare it against the `token_digest` in the database. Because the refresh tokens are stored in the client, we don't want to exceed 14 days. Effectively, the 14 days period is a "if no activity, require login" period. If you were making an API for other backends, you could make the refresh period much longer, but you most likely want to use a different authentication flow.

```ruby
# rails g model RefreshToken
class CreateRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :refresh_tokens do |t|
      t.belongs_to :user, null: false, index: true, foreign_key: true
      t.string :token_digest, null: false, index: { unique: true }
      t.datetime :revoked_at
      t.datetime :expired_at, null: false

      t.timestamps
    end
  end
end
```

```ruby
# app/models/refresh_token.rb
class RefreshToken < ApplicationRecord

  EXPIRATION_PERIOD = 14.days

  attribute :token
  attr_readonly :token_digest, :expired_at

  belongs_to :user

  before_validation :set_token_digest, on: :create
  before_validation :set_expired_at, on: :create

  def self.find_by_token(token)
    digested_token = Digest::SHA256.hexdigest(token.to_s)
    find_by(token_digest: digested_token)
  end

  def revoked?
    !revoked_at.nil?
  end

  def expired?
    expired_at <= Time.current
  end

  def valid_token?
    !revoked? && !expired?
  end

  private

    def set_token_digest
      self.token = SecureRandom.hex
      self.token_digest = Digest::SHA256.hexdigest(token)
    end

    def set_expired_at
      self.expired_at = Time.current + EXPIRATION_PERIOD
    end

end
```

#### 4. Create the login controller

We are exchanging _valid_ login credentials for an access token and a refresh token. This step doesn't require authentication, so you need the `skip_before_action` line if you followed this doc. First we check for valid credentials, then we invalidate existing tokens, the return the new token pair.

```ruby
class Api::V1::LoginController < Api::V1::ApplicationController

  skip_before_action :authenticate_user!

  def create
    if validate_login_credentials
      invalidate_existing_tokens
      render json: token_response, status: :ok
    else
      render json: { errors: "Invalid login credentials" }, status: :unauthorized
    end
  end

  private

    def login_params
      params.permit(:email, :password)
    end

    def validate_login_credentials
      @user = User.find_by_email(login_params[:email].downcase)
      @user&.authenticate(login_params[:password].strip)
    end

    def invalidate_existing_tokens
      # There should be only 1 unrevoked refresh token, but code defensively.
      # You could also create a unrevoked scope on RefreshTokens
      # and a unrevoked_refresh_tokens association on User
      # @user.unrevoked_refresh_tokens.update_all(revoked_at: Time.current)
      @user.refresh_tokens.where(revoked_at: nil).update_all(revoked_at: Time.current)
    end

    def token_response
      {
        access_token:  JsonWebToken.access_token(@user),
        refresh_token: @user.refresh_tokens.create!.token
      }
    end

end
```

#### 5. Authenticate the access token

First, we need to grab the bearer token from the header, which is the access token. Next we validate the access token by decoding the JWT and finding the User associated with the token. Finally, we set the user obtained from the token to current_user. We render the unauthorized access error if anything goes wrong.

You may want to put this in a separate module.

```ruby
class Api::V1::ApplicationController < ActionController::API

  before_action :authenticate_user!

  before_action :set_format

  helper_method :current_user

  private

    attr_reader :current_user

    def authenticate_user!
      if payload && payload_user
        @current_user = payload_user
      else
        render_unauthorized_error
      end
    end

    def payload_user
      User.find_by_id(payload["user_id"].to_i)
    end

    def payload
      JsonWebToken.decode(access_token)
    end

    def access_token
      request.headers["Authorization"]&.split("Bearer ")&.last
    end

    def set_format
      request.format = :json
    end

    def render_unauthorized_error
      render json: { errors: "Unauthorized Access" }, status: :unauthorized
    end

end
```

#### 6. Rotate the refresh token and refresh the access token

Non-revoked and non-expired (i.e valid) refresh tokens can be exchanged for a new access token and refresh token. Invalid refresh token require the user to log in again.

Rotating the refresh tokens means, the user will not need to log in again after 14 days. Conversely, after 14 days of inactivity, the user will need to login. If you want to set a hard limit (login once per month) you will need to implement a different mechanism.

```ruby
class Api::V1::RefreshTokensController < Api::V1::ApplicationController

  skip_before_action :authenticate_user!

  def create
    if validate_refresh_token
      @user = @refresh_token.user
      invalidate_existing_tokens
      render json: token_response, status: :ok
    else
      render json: { errors: [UnauthorizedError.new] }, status: :unauthorized
    end
  end

  private

    def token_params
      params.permit(:refresh_token)
    end

    def validate_refresh_token
      @refresh_token = RefreshToken.find_by_token(token_params[:refresh_token])
      @refresh_token&.valid_token?
    end

    def invalidate_existing_tokens
      @user.refresh_tokens.where(revoked_at: nil).update_all(revoked_at: Time.current)
    end

    def token_response
      {
        access_token:  JsonWebToken.access_token(@user),
        refresh_token: @user.refresh_tokens.create!.token
      }
    end

end
```
