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

      json_members = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/feeds/#{feed['id']}/recipients?pageSize=0" do |req|
        req.params['limit'] = 100
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      end
      response = JSON.parse json_members.body


      if response['recipients'].present?

        response['recipients'].each do |m|
          member = Member.find_by(threema_id: m['id'])
          if member
            if member.feeds.exclude?(new_feed)
              member.feeds << new_feed
              member.save
            end
          #else member not found -> new member by id...
          end
        end

        if new_feed.members.count != response['recipients'].count
          new_feed.members.each do |member|
            if response['recipients'].map { |m| m['id'] }.exclude?(member.threema_id)
              new_feed.members.delete(member)
            end
          end
        end

      end


    end

  end
end
