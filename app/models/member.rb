class Member < ApplicationRecord
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members

  has_many :list_members, dependent: :destroy
  has_many :distribution_lists, through: :list_members

  has_many :feed_members, dependent: :destroy
  has_many :feeds, through: :feed_members

  default_scope {order(last_name: :asc)}

  validates_uniqueness_of :threema_id, :allow_blank => true, :allow_nil => true


  def name
    self.first_name + " " + self.last_name if self.first_name && self.last_name
  end

  def self.sync_members_of_group(group)
    if group.threema_id
      json_members = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_ID']}/groups/#{group.threema_id}/members?pageSize=0" do |req|
        req.params['limit'] = 100
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-API-Key'] = ENV['BROADCAST_API_KEY']
        #req.body = {query: 'salmon'}.to_json
      end
      response = JSON.parse json_members.body

      response['members'].each do |m|

        member = Member.find_by(threema_id: m['id'])
          if member.groups.exclude?(group)
            member.groups << group
            member.save
          end
        end

        if group.members.count != response['members'].count
          group.members.each do |member|
            if response['members'].map { |m| m['id'] }.exclude?(member.threema_id)
              group.members.delete(member)
            end
          end
        end

      end
    end

    def self.get_members_from_threema_work
      json_members = Faraday.get "https://work.threema.ch/api/v1/users?pageSize=0" do |req|
        req.params['limit'] = 100
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-API-Key'] = ENV['WORK_API_KEY']
      end
      response = JSON.parse json_members.body

      response['users'].each do |m|
        member = Member.find_or_initialize_by(threema_id: m['id'])
        member.update_attribute(:first_name, m['firstName']) #if m['firstName'] #!= member.first_name
        member.update_attribute(:last_name, m['lastName']) #if m['lastName'] #!= member.last_name
        member.update_attribute(:category, m['category'])# if m['category'] #!= member.category
        member.update_attribute(:nickname, m['nickname'])# if m['category'] #!= member.category
      end

    end



  end
