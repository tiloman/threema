# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == ENV['DELAYED_USER'] && password == ENV['DELAYED_PW']
  end
end


run Rails.application
