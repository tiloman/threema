class AdminMailer < ApplicationMailer

  def new_user(user, admin)
    @user = user
    mail(to: admin.email, subject: 'Neuer Benutzer bei Threema AJG')
  end

  def invitation_accepted(user, admin)
    @user = user
    mail(to: admin.email, subject: 'Neuer Benutzer bei Threema AJG')
  end

  def new_group_request(user, group, admin)
    @user = user
    @group = group
    mail(to: admin.email, subject: 'Neue Gruppe')
  end
end
