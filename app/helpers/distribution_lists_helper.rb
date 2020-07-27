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


  def update_list_attributes(list, name)
    if list.threema_id
      data = {:name => name}
      request = Faraday.put "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/distribution_lists/#{list.threema_id}" do |req|
        req.params['limit'] = 100
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
        req.body = data.to_json
      end

      return [request.body, request.status]
    end
  end

  def update_recipients(list)
    if missing_local = missing_local_recipients(list)
       remove_recipients(list, missing_local)
    end

    if missing_remote = missing_remote_recipients(list)
       add_recipients(list, missing_remote)
    end
  end

  def remove_recipients(list, members)
    data = {:recipients => members}

    puts data
    request = Faraday.delete "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/distribution_lists/#{list.threema_id}/recipients" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      req.body = data.to_json
    end
    puts request.status
  end

  def add_recipients(list, members)
    data = {:recipients => members,
    :replaceExisting => false}
    request = Faraday.post "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/distribution_lists/#{list.threema_id}/recipients" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      req.body = data.to_json
    end
    request.body
  end



  def create_list(list, name)
    data = {:name => name}
    response_json = Faraday.post "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/distribution_lists" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      req.body = data.to_json
    end


    response = JSON.parse response_json.body
    list.update_attribute(:threema_id, response['id'])
    list.reload
    update_recipients(list)
    return response

  end


  def missing_local_recipients(list)
    missing = []
    local_members = list.members

    get_recipients_from_server(list).each do |member|
      if local_members.map { |m| m.threema_id }.exclude?(member['id'])
        missing << member['id']
      end
    end
    return missing if missing.length > 0
  end

def missing_remote_recipients(list)
  missing = []
  server_members = get_recipients_from_server(list)

  list.members.each do |member|
    if server_members.map { |m| m['id'] }.exclude?(member.threema_id)
      missing << member.threema_id
    end
  end
  return missing if missing.length > 0
end

def get_recipients_from_server(list)
  json_members = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/distribution_lists/#{list.threema_id}/recipients?pageSize=0" do |req|
    req.params['limit'] = 100
    req.headers['Content-Type'] = 'application/json'
    req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
    #req.body = {query: 'salmon'}.to_json
  end
  response = JSON.parse json_members.body
  puts response['recipients']
  return response['recipients']
end


end
