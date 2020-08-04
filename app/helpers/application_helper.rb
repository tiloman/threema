module ApplicationHelper

  def pending_group_requests
    Group.local_groups.count if current_user.is_management_or_higher
  end

end
