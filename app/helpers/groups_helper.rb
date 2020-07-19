module GroupsHelper

  def update_group_attributes(group, name, saveChatHistory)
    data = {:name => name,
            :saveChatHistory => saveChatHistory
            }
    request = Faraday.put "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups/#{group.threema_id}" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      req.body = data.to_json
    end

    request
  end

  def get_threema_ids(member_ids)
    Member.where(id: member_ids).map { |m| m['threema_id'] }
  end

  def update_members(group)
    if missing_local = missing_local_members(group)
       remove_members(group, missing_local)
    end

    if missing_remote = missing_remote_members(group)
       add_members(group, missing_remote)
    end
  end

  def remove_members(group, members)
    request = Faraday.delete "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups/#{group.threema_id}/members" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      req.body = members.to_json
    end
    puts request.status
  end

  def add_members(group, members)
    request = Faraday.post "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups/#{group.threema_id}/members" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      req.body = members.to_json
    end
    request.body
  end


  def missing_local_members(group)
    missing = []
    local_members = group.members

    get_members_from_server(group).each do |member|
      if local_members.map { |m| m.threema_id }.exclude?(member['id'])
        missing << member['id']
      end
    end
    return missing if missing.length > 0
  end

  def missing_remote_members(group)
    missing = []
    server_members = get_members_from_server(group)

    group.members.each do |member|
      if server_members.map { |m| m['id'] }.exclude?(member.threema_id)
        missing << member.threema_id
      end
    end
    return missing if missing.length > 0
  end

  def get_members_from_server(group)
    json_members = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups/#{group.threema_id}/members?pageSize=0" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      #req.body = {query: 'salmon'}.to_json
    end
    response = JSON.parse json_members.body

    response['members']
  end

  def delete_group_from_threema(group)
    request = Faraday.delete "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups/#{group.threema_id}" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
    end
    request.status
  end

end
