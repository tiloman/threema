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


  def get_username_from_threema_work
    user_details_response = Faraday.get "https://work.threema.ch/api/v1/users/#{self.threema_id}" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['WORK_API_KEY']
    end
    #response = credentials
    user_details = JSON.parse user_details_response.body
    link = user_details['_links'][1]['link']

    puts link
    credentials_response = Faraday.get link do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['WORK_API_KEY']
    end

    credentials = JSON.parse credentials_response.body

    return credentials['username']

  end


  def self.get_members_from_threema_work
    json_members = Faraday.get "https://work.threema.ch/api/v1/users?pageSize=0" do |req|
      req.params['limit'] = 100
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-API-Key'] = ENV['WORK_API_KEY']
    end
    response = JSON.parse json_members.body

    if response['users'].present?

      response['users'].each do |m|
        member = Member.find_or_create_by(threema_id: m['id'])
        member.update_column(:first_name, m['firstName']) if m['firstName'] != member.first_name
        member.update_column(:last_name, m['lastName']) if m['lastName'] != member.last_name
        member.update_column(:category, m['category']) if m['category'] != member.category
        member.update_column(:nickname, m['nickname']) if m['nickname'] != member.nickname
        #member.update_column(:username, m['username']) if m['username'] != member.username

      end

      if Member.all.count != response['users'].count
        Member.all.each do |member|
          if response['users'].map { |m| m['id'] }.exclude?(member.threema_id)
            member.destroy
          end
        end
      end

    end

  end



  end
