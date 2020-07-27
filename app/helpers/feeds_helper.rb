module FeedsHelper

  def send_feed_message(feed, message)
    data = {type: "text",
            body: {"de": message},
            }
    response_json = Faraday.post "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/feeds/#{feed.threema_id}/chat" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      req.body = data.to_json
    end


    response = JSON.parse response_json.body

    return response

  end


  def get_feed_chat(feed)
    response_json = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/feeds/#{feed.threema_id}/chat" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      #req.body = data.to_json
    end


    response = JSON.parse response_json.body

    return response['messages']
  end
end
