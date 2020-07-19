# Load the Rails application.
require_relative 'application'


# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
local_env = File.join(Rails.root, 'config', 'local_env.rb')
load(local_env) if File.exists?(local_env)


# Initialize the Rails application.
Rails.application.initialize!
