class SyncGroupImagesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Group.each do |group|
      response_json = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups/#{group.threema_id}/image" do |req|
        req.params['limit'] = 100
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      end

      response = JSON.parse response_json.body
      group.update_attribute(:image, response['image'])
    end
  end
end
