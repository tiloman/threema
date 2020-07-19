class Member < ApplicationRecord
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members


  def name
    self.first_name + " " + self.last_name if self.first_name && self.last_name
  end

  def self.sync_members_of_group(group)

    if group.threema_id
      json_members = Faraday.get "https://broadcast.threema.ch/api/v1/identities/#{ENV['BROADCAST_API_KEY']}/groups/#{group.threema_id}/members?pageSize=0" do |req|
        req.params['limit'] = 100
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-API-Key'] = 'KH4RJ66FT39SLA7EED56A8Y4M92R82PM'
        #req.body = {query: 'salmon'}.to_json
      end
      response = JSON.parse json_members.body

      response['members'].each do |member|
        member = Member.find_or_create_by!(
          first_name: member['firstName'],
          last_name: member['lastName'],
          threema_id: member['id']
          )


          if member.groups.exclude?(group)
            member.groups << group
            member.save
          end
        end

        if group.members.count != response['members'].count
          puts "**********ungelich*******"
          group.members.each do |member|

            if response['members'].map { |m| m['id'] }.exclude?(member.threema_id)
              puts "#{member} sollte gelöscht werden."
              group.members.delete(member)
            end
          end




        end
      end
    end
  end
