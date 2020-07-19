class SyncMembersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Group.all.each do |group|
      Member.sync_members_of_group(group)
    end
  end
end
