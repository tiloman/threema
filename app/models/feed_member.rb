class FeedMember < ApplicationRecord
  belongs_to :member
  belongs_to :feed
end
