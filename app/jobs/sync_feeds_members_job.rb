class SyncFeedsMembersJob < ApplicationJob
  queue_as :default

  def perform(*args)

    Feed.all.each do |feed|

      json_members = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/feeds/#{feed.threema_id}/recipients?pageSize=0" do |req|
        req.params['limit'] = 100
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      end
      response = JSON.parse json_members.body

      puts response

      response['recipients'].each do |m|

        member = Member.find_by(threema_id: m['id'])
          if member.feeds.exclude?(feed)
            member.feeds << feed
            member.save
          end
        end

        if feed.members.count != response['recipients'].count
          feed.members.each do |member|
            if response['recipients'].map { |m| m['id'] }.exclude?(member.threema_id)
              feed.members.delete(member)
            end
          end
        end

    end

  end
end
