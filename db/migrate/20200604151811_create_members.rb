class CreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :last_name
      t.string :threema_id
      t.timestamps
    end
  end
end
