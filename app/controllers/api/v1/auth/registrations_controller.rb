class Api::V1::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController
  # def create
  #   @user = User.new(sign_up_params)
  #   @user.save!
  #   render json: @user
  # end

  private

    def sign_up_params
      params.permit(:name, :email, :password, :password_confirmation)
    end

    def account_update_params
      params.permit(:name, :email)
    end
end
