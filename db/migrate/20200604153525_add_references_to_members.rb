class AddReferencesToMembers < ActiveRecord::Migration[5.2]
  def change
    add_reference :members, :group, index: true
  end
end
