class ApplicationJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    #schedule new jobs every x hours due to lack of cronjobs in dokku
    ApplicationJob.set(wait: 3.hour).perform_later

    #clean up before scheduling
    Delayed::Job.where("handler ilike (?)", "%SyncFeedsJob%").destroy_all
    Delayed::Job.where("handler ilike (?)", "%SyncListMembersJob%").destroy_all
    Delayed::Job.where("handler ilike (?)", "%SyncListsJob%").destroy_all
    Delayed::Job.where("handler ilike (?)", "%SyncGroupImagesJob%").destroy_all
    Delayed::Job.where("handler ilike (?)", "%SyncGroupsJob%").destroy_all
    Delayed::Job.where("handler ilike (?)", "%SyncMembersJob%").destroy_all


    #get all groups and update attributes
    #requests for 300 groups: 1x for all groups; 300x for each group
    SyncGroupsJob.perform_later

    #get all members from threema work
    #request 1x for getting all members
    SyncMembersJob.perform_later

    #get group images
    #300 requests
    SyncGroupImagesJob.perform_later

    #1 request for alle groups
    SyncListsJob.perform_later

    #30 requests for each list
    SyncListMembersJob.perform_later

    #1 for all feeds and 10 for each feed
    SyncFeedsJob.perform_later

    #overall requests 644







  end
end
