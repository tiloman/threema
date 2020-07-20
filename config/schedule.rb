every 1.hours do
  runner 'SyncGroupsJob.perform_later'
end

every 1.hours do
  runner 'SyncMembersJob.perform_later'
end

every 1.hours do
  runner 'SyncGroupImagesJob.perform_later'
end
