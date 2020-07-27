class CreateFeedMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :feed_members do |t|
       t.references :member, foreign_key: true
      t.references :feed, foreign_key: true
    end
  end
end
