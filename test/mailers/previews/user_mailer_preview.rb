# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    UserMailer.welcome_email(User.first)
  end

  def role_changed
    UserMailer.role_changed(User.first, ["Verwaltung", "Benutzer"])
  end

  def group_requested
    UserMailer.group_requested(Group.first, User.first)
  end

  def group_approved
    UserMailer.group_approved(Group.first, User.first)
  end

end
