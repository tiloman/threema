class SyncFeedsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    response_json = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/feeds" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
    end

    response = JSON.parse response_json.body

    response['feeds'].each do |feed|
      new_feed = Feed.find_or_create_by(threema_id: feed['id'])
      new_feed.update_attribute(:name, feed['name']) if feed['name'] != new_feed.name
    end

  end
end
