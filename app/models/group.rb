class Group < ApplicationRecord

  has_many :group_members , dependent: :destroy
  has_many :members, through: :group_members

  validates_uniqueness_of :threema_id, :allow_blank => true, :allow_nil => true


  # after_update: :update_group_attributes

require 'faraday'

  def self.sync_groups
    response_json = Faraday.get 'https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_API_KEY']}/groups' do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = 'KH4RJ66FT39SLA7EED56A8Y4M92R82PM'
    end

    response = JSON.parse response_json.body

    response['groups'].each do |group|
      new_group = Group.find_or_create_by(name: group['name'], threema_id: group['id'])
      if group['name'] != new_group.name
        new_group.update_attribute(:name, group['name'])
      elsif group['state'] != new_group.state
        new_group.update_attribute(:state, group['state'])
      elsif group['saveChatHistory'] != new_group.saveChatHistory
        new_group.update_attribute(:saveChatHistory, group['saveChatHistory'])
      end
    end
  end

  def show_infos
    response_json = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_API_KEY']}/groups" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = 'KH4RJ66FT39SLA7EED56A8Y4M92R82PM'
    end

    puts response_json.status
    response = JSON.parse response_json.body
  end

  def get_image
    response_json = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_API_KEY']}/groups/#{self.threema_id}/image" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = 'KH4RJ66FT39SLA7EED56A8Y4M92R82PM'
    end

    response = JSON.parse response_json.body
    self.update_attribute(:image, response['image'])
  end

  def get_members_from_server
    json_members = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_API_KEY']}/groups/#{self.threema_id}/members?pageSize=0" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = 'KH4RJ66FT39SLA7EED56A8Y4M92R82PM'
      #req.body = {query: 'salmon'}.to_json
    end
    response = JSON.parse json_members.body

    response['members']
  end

  def delete_from_threema
    json_members = Faraday.delete "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_API_KEY']}/groups/#{self.threema_id}" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = 'KH4RJ66FT39SLA7EED56A8Y4M92R82PM'
    end
    json_members.status
  end

  def update_group_attributes
    data = {:name => self.name,
            :members => self.members.map { |m| m['threema_id'] },
            :saveChatHistory => false
            }

    json_members = Faraday.put "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_API_KEY']}/groups/#{self.threema_id}" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = 'KH4RJ66FT39SLA7EED56A8Y4M92R82PM'
      req.body = data.to_json
    end

    json_members.status
  end

end
