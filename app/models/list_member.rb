class ListMember < ApplicationRecord
  belongs_to :member
  belongs_to :distribution_list
end
