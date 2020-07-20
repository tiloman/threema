class SyncGroupsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    response_json = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
    end

    response = JSON.parse response_json.body

    response['groups'].each do |group|
      new_group = Group.find_or_create_by(threema_id: group['id'])
      new_group.update_attribute(:name, group['name']) if group['name'] != new_group.name
      new_group.update_attribute(:state, group['state']) if group['state'] != new_group.state
      new_group.update_attribute(:saveChatHistory, group['saveChatHistory']) if group['saveChatHistory'] != new_group.saveChatHistory
    end

  end
end
