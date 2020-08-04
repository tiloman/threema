class Users::InvitationsController < Devise::InvitationsController
  layout :resolve_layout

  before_action :configure_permitted_parameters, if: :devise_controller?




  private

  def after_invite_path_for(resource)
      users_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite) do |u|
      u.permit(:email, :role)
    end

    devise_parameter_sanitizer.permit(:accept_invitation) do |u|
      u.permit(:first_name, :last_name, :password, :password_confirmation, :invitation_token, :threema_id)
    end
  end

  def resolve_layout
    case action_name
    when "edit", "update"
      "logged_out"
    else
      "application"
    end
  end
end
