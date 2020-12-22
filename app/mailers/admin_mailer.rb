class AdminMailer < ApplicationMailer

  def new_user(user, admin)
    if admin.mail_admin_new_user
      @user = user
      mail(to: admin.email, subject: 'Neuer Benutzer bei Threema AJG')
    end
  end

  def invitation_accepted(user, admin)
    if admin.mail_admin_invitation_accepted
      @user = user
      mail(to: admin.email, subject: 'Neuer Benutzer bei Threema AJG')
    end
  end

  def new_group_request(user, group, admin)
    if admin.mail_admin_new_group_request
      @user = user
      @group = group
      mail(to: admin.email, subject: 'Neue Gruppe')
    end
  end

  def daily_info(admin)
    if admin.mail_admin_daily_info
      @admin = admin
      @groups = Group.where(threema_id: [nil,""])
      @new_users = User.where("created_at BETWEEN ? AND ?", Time.now - 24.hours , Time.now)
      @unconfirmed_users = User.where(role: [nil, '', "Unbestätigt", "unconfirmed"])
      mail(to: admin.email, subject: 'Neuigkeiten bei Threema AJG') if @groups.any? || @new_users.any? || @unconfirmed_users.any?
    end
  end

  def error_log(error_message, job )
    @error_message = error_message
    @job = job
    mail(to: "lohmanntimo@gmail.com", subject: 'Fehler bei Threema4teachers')
  end

end
