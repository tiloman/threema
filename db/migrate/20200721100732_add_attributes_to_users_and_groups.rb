class AddAttributesToUsersAndGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :category, :string
    add_column :members, :avatar, :string
    add_column :users, :role, :string, default: "unconfirmed"
    add_column :users, :threema_id, :string
  end
end
