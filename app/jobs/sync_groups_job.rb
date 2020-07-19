class SyncGroupsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Group.sync_groups

    Group.all.each do |group|
      Member.sync_members_of_group(group)
      group.get_image
    end

  end
end
