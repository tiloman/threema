class UsersController < ApplicationController
  #before_action :is_admin?

  def index
    @users = User.all
  end

  def update_user_role
    user = User.find(params[:id])
    if user.update_attributes!(role: params[:role])
      respond_to do |format|
        format.html { redirect_to  users_path, notice: "#{user.first_name} wurde aktualisiert." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to users_path, notice: "Fehler" }
        format.json { head :no_content }
      end
    end
  end

end
