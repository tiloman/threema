module ApplicationHelper

  def pending_group_requests
    if current_user.is_management_or_higher
      Group.local_groups.count
    else
      return 0
    end 
  end

end
