class CreateDistributionLists < ActiveRecord::Migration[5.2]
  def change
    create_table :distribution_lists do |t|
      t.string :name
      t.string :threema_id
      t.string :state 
      t.timestamps
    end
  end
end
