class SyncListMembersJob < ApplicationJob
  queue_as :default

  def perform(*args)

    DistributionList.all.each do |list|

      json_members = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/distribution_lists/#{list.threema_id}/recipients?pageSize=0" do |req|
        req.params['limit'] = 100
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
        #req.body = {query: 'salmon'}.to_json
      end
      response = JSON.parse json_members.body

      puts response

      response['recipients'].each do |m|

        member = Member.find_by(threema_id: m['id'])
          if member.distribution_lists.exclude?(list)
            member.distribution_lists << list
            member.save
          end
        end

        if list.members.count != response['recipients'].count
          list.members.each do |member|
            if response['recipients'].map { |m| m['id'] }.exclude?(member.threema_id)
              list.members.delete(member)
            end
          end
        end
        
    end

  end
end