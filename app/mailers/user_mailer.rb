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

  def group_requested(group, user)
    @user = user
    @group = group
    mail(to: @user.email, subject: 'Threema AJG | Anfrage zur Gruppengründung')
  end

  def group_approved(group, user)
    @user = user
    @group = group
    mail(to: @user.email, subject: 'Threema AJG | Deine Gruppe wurde genehmigt.')
  end
end
