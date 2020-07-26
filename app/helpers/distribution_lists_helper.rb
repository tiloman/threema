module DistributionListsHelper

  def send_list_message(list, message)
    data = {type: "text",
            body: {"de": message},
            }
    response_json = Faraday.post "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/distribution_lists/#{list.threema_id}/chat" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      req.body = data.to_json
    end


    response = JSON.parse response_json.body

    return response unless response == 204

  end
end
