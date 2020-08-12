class AddMailNotificationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mail_admin_new_user, :boolean, default: true
    add_column :users, :mail_admin_invitation_accepted, :boolean, default: true
    add_column :users, :mail_admin_new_group_request, :boolean, default: true
    add_column :users, :mail_admin_daily_info, :boolean, default: true
  end
end
