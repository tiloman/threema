# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.variable_size_secure_compare(ENV['DELAYED_USER'], username) &&
      ActiveSupport::SecurityUtils.variable_size_secure_compare(ENV['DELAYED_PW'], password)
  end
end


run Rails.application
