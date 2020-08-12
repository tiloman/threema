class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?


protected


  def configure_permitted_parameters
     devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit( :first_name, :last_name, :email, :password, :current_password, :threema_id, :mail_admin_new_user, :mail_admin_invitation_accepted, :mail_admin_new_group_request, :mail_admin_daily_info)}
     devise_parameter_sanitizer.permit(:account_update) { |u| u.permit( :first_name, :last_name, :email, :password, :current_password, :threema_id, :mail_admin_new_user, :mail_admin_invitation_accepted, :mail_admin_new_group_request, :mail_admin_daily_info)}
  end

  def user_confirmed_by_admin?
    if current_user
      redirect_to root_path, notice: "Dein Account wurde noch nicht bestätigt. Ein Administrator wurde benachrichtigt und wird deinen Account aktivieren." if current_user.is_unconfirmed
    end
  end

  def is_user_or_higher
    if current_user
      redirect_to root_path, notice: "Keine Berechtigung." unless current_user.is_user_or_higher
    end
  end


  def is_management_or_higher
    if current_user
      redirect_to root_path, notice: "Keine Berechtigung." unless current_user.is_management_or_higher
    end
  end


  def is_admin_or_higher
    if current_user
      redirect_to root_path, notice: "Keine Berechtigung." unless current_user.is_admin_or_higher
    end
  end

  def is_owner
    if current_user
      redirect_to root_path, notice: "Keine Berechtigung." unless current_user.is_owner
    end
  end


end
