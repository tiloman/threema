class ApplicationJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    SyncGroupsJob.perform_later
    SyncMembersJob.perform_later
    SyncGroupImagesJob.perform_later

    #schedule new jobs every x hours due to lack of cronjobs in dokku
    ApplicationJob.set(wait: 3.hour).perform_later
  end
end
