class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:login, :fio, :region_id, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password])
  end

  def after_sign_in_path_for(user)
    current_user.admin? ? vacations_path : user_path(current_user)
  end
end
