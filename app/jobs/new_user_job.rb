class NewUserJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.welcome_email(user).deliver_later

    User.admins.each do |admin|
      AdminMailer.new_user(user, admin).deliver_later
    end

  end
end
