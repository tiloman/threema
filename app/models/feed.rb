class Feed < ApplicationRecord

  has_many :feed_members , dependent: :destroy
  has_many :members, through: :feed_members

  validates_uniqueness_of :name
  validates_length_of :name, minimum: 1, maximum: 255, allow_blank: false
  default_scope {order(name: :asc)}

end
