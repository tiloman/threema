class AddAttributesToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :state, :string
    add_column :groups, :saveChatHistory, :boolean
    add_column :groups, :image, :string
  end
end
