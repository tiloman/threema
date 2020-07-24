module MembersHelper

  def current_user_member
    Member.find_by(threema_id: current_user.threema_id)
  end

end
