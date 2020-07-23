class ApplicationJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    #schedule new jobs every x hours due to lack of cronjobs in dokku
    ApplicationJob.set(wait: 3.hour).perform_later

    #get all groups and update attributes
    SyncGroupsJob.perform_later

    #get all members from threema and update their groups
    SyncMembersJob.perform_later

    #get group images 
    SyncGroupImagesJob.perform_later

  end
end
