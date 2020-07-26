# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    UserMailer.welcome_email(User.first)
  end

  def role_changed
    UserMailer.role_changed(User.first, ["Verwaltung", "Benutzer"])
  end

end
