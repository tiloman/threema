class SyncMembersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    #get all existing members from threema work
    Member.get_members_from_threema_work

    #sync each group
    # Group.all.each do |group|
    #   Member.sync_members_of_group(group)
    # end
  end
end
