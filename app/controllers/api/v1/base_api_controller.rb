class Api::V1::BaseApiController < ApplicationController
  before_action :authenticate_user!, except: [:index,:show]

  def authenticate_user!
    authenticate_api_v1_user!
  end

  def current_user
    current_api_v1_user
  end

  def user_signed_in?
    api_v1_user_signed_in?
  end
end
