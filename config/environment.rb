# Load the Rails application.
require_relative 'application'

# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
local_env = File.join(Rails.root, 'config', 'local_env.rb')
load(local_env) if File.exists?(local_env)

ActionMailer::Base.smtp_settings = {
  :user_name  => ENV['SENDGRID_USERNAME'],
  :password   => ENV['SENDGRID_PASSWORD'],
  :domain => 'heroku.com',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}


# Initialize the Rails application.
Rails.application.initialize!
