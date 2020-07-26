class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Willkommen bei Threema AJG')
  end

  def role_changed(user, change)
    @user = user
    @change = change
    mail(to: @user.email, subject: 'Threema AJG | Neue Benutzerrolle')
  end

end
