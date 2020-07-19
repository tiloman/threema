class Team < ApplicationRecord
  before_save :downcase_subdomain

private

  
  def downcase_subdomain
  self.subdomain.downcase!
end

end
