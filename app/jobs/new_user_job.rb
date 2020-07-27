class NewUserJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.welcome_email(user).deliver_later

    User.owners.each do |owner|
      AdminMailer.new_user(user, owner).deliver_later
    end

  end
end
