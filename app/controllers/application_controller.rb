class ApplicationController < ActionController::Base
before_action :set_team


protected

  def set_team
    @team = Team.find_by(subdomain: request.subdomain)
  end


end
