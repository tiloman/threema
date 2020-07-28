class FeedsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_confirmed_by_admin?
  before_action :is_management_or_higher


  include FeedsHelper

  def show
    set_feed
    @members = @feed.members
    @all_messages = get_feed_chat(@feed)

    if params[:show_all_messages].present?
      messages = @all_messages
    else
      messages = @all_messages.first(3)
    end
    @messages = messages
  end

  def index
    if params[:search].present?
      search = params[:search].downcase
      feeds = Feed.where("LOWER(name) LIKE ? ", "%#{search}%")
    else
      feeds = Feed.all
    end

    @feeds = feeds
  end

  def new_message
    @feed = Feed.find(params[:feed_id])
    @members = @feed.members

  end

  def send_feed_new_message
    feed = Feed.find(params[:feed_id])
    message = params[:message]

    response = send_feed_message(feed, message)
    respond_to do |format|
      format.html { redirect_to feed, notice: "Die Nachricht wurde versendet. Es kann einige Minuten dauern bis Nachricht angezeigt wird. \n #{message}" }
      format.json { head :no_content }
    end
  end

  private

  def set_feed
    @feed = Feed.find(params[:id])

  end
end
