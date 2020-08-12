# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview

  def new_user
    AdminMailer.new_user(User.first, User.first)
  end

  def invitation_accepted
    AdminMailer.invitation_accepted(User.first, User.first)
  end

  def new_group_request
    AdminMailer.new_group_request(User.first, Group.first, User.first)
  end

  def daily_info
    AdminMailer.daily_info(User.first)
  end

end
