class SyncListsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    response_json = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/distribution_lists" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
    end

    response = JSON.parse response_json.body

    if response['distributionLists'].present?
      response['distributionLists'].each do |list|
        new_list = DistributionList.find_or_create_by(threema_id: list['id'])
        new_list.update_attribute(:name, list['name']) if list['name'] != new_list.name
        new_list.update_attribute(:state, list['state']) if list['state'] != new_list.state
      end
    else
      #AdminMailer.error_log(response, "SyncListsJob").deliver_later
    end
  end
end
