class Feed < ApplicationRecord

  has_many :feed_members , dependent: :destroy
  has_many :members, through: :feed_members
end
