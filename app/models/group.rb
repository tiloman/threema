class Group < ApplicationRecord
  has_many :group_members , dependent: :destroy
  has_many :members, through: :group_members

  validates_uniqueness_of :threema_id, :allow_blank => true, :allow_nil => true
  validates_length_of :name, minimum: 1, maximum: 255, allow_blank: false
  validates_uniqueness_of :name

  default_scope {where(state: "active")}.sort
  scope :include_deleted, -> { self.all.unscoped }
  scope :local_groups, -> { where(threema_id: ['', nil]) }


end
