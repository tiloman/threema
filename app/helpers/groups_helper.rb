module GroupsHelper

  def update_group_attributes(group, name, saveChatHistory)
    if group.threema_id
      data = {:name => name,
              :saveChatHistory => ActiveRecord::Type::Boolean.new.cast(saveChatHistory)
              }
      request = Faraday.put "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups/#{group.threema_id}" do |req|
        req.params['limit'] = 100
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
        req.body = data.to_json
      end

      request.status
    end
  end


  def create_group(group, name, members, saveChatHistory)

    data = {:name => name,
            :members => members,
            :saveChatHistory => ActiveRecord::Type::Boolean.new.cast(saveChatHistory)
            }
    response_json = Faraday.post "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
      req.body = data.to_json
    end


    response = JSON.parse response_json.body
    group.update_attribute(:threema_id, response['id'])
    puts response['id']
    puts "*******************RESPONES***********"
    return response['id']
  end

  def get_threema_ids(member_ids)
    Member.where(id: member_ids).map { |m| m['threema_id'] }
  end

  def update_members(group)
    server_members = get_members_from_server(group)
    if missing_local = missing_local_members(group, server_members)
       remove_members(group, missing_local)
    end

    if missing_remote = missing_remote_members(group, server_members)
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


  def missing_local_members(group, server_members)
    missing = []
    local_members = group.members

    server_members.each do |member|
      if local_members.map { |m| m.threema_id }.exclude?(member['id'])
        missing << member['id']
      end
    end
    return missing if missing.length > 0
  end

  def missing_remote_members(group, server_members)
    missing = []

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
    puts request.status
    puts "***********************"
    return request.status
  end

  def show_image(group)
    if group.avatar.present?
      image_tag group.avatar.url(:medium) , class:"group-image"
    elsif group.image
      data = "data:image/jpeg;base64,#{group.image}"
      image_tag data, class:"group-image"
    else
      render html: '<div class="group-image"><i class="fas fa-users"></i></div>'.html_safe
    end
  end

  def show_big_image(group)
    if group.avatar.present?
      image_tag group.avatar.url(:medium) , class:"group-image-big"
    elsif group.image
      data = "data:image/jpeg;base64,#{group.image}"
      image_tag data, class:"group-image-big"
    else
      render html: '<div class="group-image-big"><i class="fas fa-users"></i></div>'.html_safe
    end
  end

def get_heading_for_table(action, group)
  if action != "show"
    render html: '<br><br><h3>Mitglieder mit Hilfe der Tabelle hinzufügen</h3><br>'.html_safe
  else
    render html: "<br><br><h3>#{group.members.count} Mitglieder</h3>".html_safe
  end
end





end
