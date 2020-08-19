class UsersController < ApplicationController
  before_action :user_confirmed_by_admin?
  before_action :is_owner


  def index
    @users = User.where.not(first_name: ['', nil])
    @invited_users = User.where(first_name: ['', nil])
    @unconfirmed_users = User.where(role: "Unbestätigt")
  end

  def update_user_role
    user = User.find(params[:id])
    user.assign_attributes(role: params[:role])
    if user.save(validate: false)
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

  def destroy
   @user = User.find(params[:id])
   @user.destroy

   if @user.destroy
       redirect_to users_url, notice: "Benutzer gelöscht."
   end
 end

end
