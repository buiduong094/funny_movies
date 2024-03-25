class AuthenticationController < ApplicationController
    skip_before_action :authenticate, only: [:signin, :signup]

    def signin
        @user = User.find_by(username: params[:username])
        if @user
            if(@user.authenticate(params[:password]))
                payload = {user_id: @user.id}
                secret = ENV['SECRET_KEY_BASE'] ||  Rails.application.secrets.secret_key_base
                token = create_token(payload)
                render json:
                {
                    id: @user.id,
                    username: @user.username,
                    email: @user.email,
                    accessToken: token,
                    username: @user.username,
                    roles: [
                        "ROLE_USER"
                    ],
                    "tokenType": "Bearer"
                }
            else
                render json: { message: "Authentication Failure"}, status: :unprocessable_entity
            end
        else
            render json: { message: "Could not find user"}, status: :unprocessable_entity
        end
    end

    def signup
        @user = User.new(user_params)

        begin
            if @user.save
                payload = { user_id: @user.id }
                token = create_token(payload)
                render json: {message: "User registered successfully!"}, status: :created, location: @user
            else
                render json: {message: "Cannot create a user. Please try again!"}, status: :unprocessable_entity
            end
        rescue => e
            render json: {message: "Cann't Register. Please check the username or email!"}, status: :unprocessable_entity
        else
            #... executes when no error
        ensure
            #... always executed
        end
    end

    private
      # Never trust parameters from the scary internet, only allow the white list through.
      def user_params
        params.require(:authentication).permit(:username, :password, :email)
      end
end
