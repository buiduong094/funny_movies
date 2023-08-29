class ApplicationController < ActionController::Base
    before_action :authenticate
    protect_from_forgery with: :null_session
    def authenticate
        if request.headers["Authorization"]
            begin 
                # decoded_token = JWT.decode(token, secret) 
                # payload = decoded_token.first
                # user_id = payload["user_id"]
                # @user = User.find(user_id) 
                @user = current_user
            rescue => exception 
                render json: {message: "Error: #{exception}"}, status: :forbidden
            end
        else
            render json: {message: "No Authorization header sent"}, status: :forbidden
        end
    end

    def token
        puts request.headers["Authorization"].split(" ")[1]
        request.headers["Authorization"].split(" ")[1]
    end

    def secret
        secret = ENV['SECRET_KEY_BASE'] || Rails.application.secrets.secret_key_base
    end

    def create_token(payload)
        JWT.encode(payload, secret)
    end

    def current_user
        return nil unless request.headers["Authorization"].present?
        decoded_token = JWT.decode(token, secret) 
        payload = decoded_token.first
        user_id = payload["user_id"]
        puts "userid is #{user_id}"
        @current_user = User.find(user_id) 
    end

end
