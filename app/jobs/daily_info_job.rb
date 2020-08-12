class DailyInfoJob < ApplicationJob
  queue_as :default

  def perform(*args)
    DailyInfoJob.set(wait: 24.hour).perform_later

    User.owners.each do |owner|
      AdminMailer.daily_info(owner).deliver_later
    end
  end
end
