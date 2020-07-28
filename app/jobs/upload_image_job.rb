class UploadImageJob < ApplicationJob
  queue_as :default

  def perform(group)
    base64_string =  Base64.encode64(open("https:#{group.avatar.url(:medium)}") { |io| io.read })

        data = {:image => base64_string }
        response_json = Faraday.put "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups#{group.threema_id}/image" do |req|
          req.params['limit'] = 100
          req.headers['Content-Type'] = 'application/json'
          req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
          req.body = data.to_json
        end


        response = JSON.parse response_json.body

        response
      end
  end
end
