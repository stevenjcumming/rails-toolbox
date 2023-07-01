class Api::V1::ApplicationController < ActionController::API

  include ActionController::Caching

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