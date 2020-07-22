class HomeController < ApplicationController
  #before_action :authenticate_user!
  layout :resolve_layout

  def index
  end

  def impressum
  end

  protected

  def resolve_layout
    case action_name
    when "impressum"
      "logged_out"
    else
      "application"
    end
  end
end
