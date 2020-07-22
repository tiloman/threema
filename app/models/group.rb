class Group < ApplicationRecord
  has_many :group_members , dependent: :destroy
  has_many :members, through: :group_members

  validates_uniqueness_of :threema_id, :allow_blank => true, :allow_nil => true


end
