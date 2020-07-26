class CreateListMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :list_members do |t|

      t.references :member, foreign_key: true
      t.references :distribution_list, foreign_key: true

    end
  end
end
