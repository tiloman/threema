module ApplicationHelper


  def pending_group_requests
    Group.local_groups.count
  end
  
end
