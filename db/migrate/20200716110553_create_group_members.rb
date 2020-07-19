class CreateGroupMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :group_members do |t|
      t.references :member, foreign_key: true
      t.references :group, foreign_key: true

      t.timestamps
    end

    remove_reference :members, :group

  end
end
