class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?


protected


  def configure_permitted_parameters
     devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit( :first_name, :last_name, :email, :password, :current_password, :threema_id)}
     devise_parameter_sanitizer.permit(:account_update) { |u| u.permit( :first_name, :last_name, :email, :password, :current_password, :threema_id)}
  end

  def is_admin?
    if current_user
      redirect_to root_path, notice: "Keine Berechtigung." unless current_user.role == "Administrator"
    end
  end

  def user_confirmed_by_admin?
    if current_user
      redirect_to root_path, notice: "Dein Account wurde noch nicht bestätigt." if current_user.role == "Unconfirmed"
    end
  end
end
