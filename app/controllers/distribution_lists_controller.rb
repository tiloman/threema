class DistributionListsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_confirmed_by_admin?
  before_action :is_admin?

  include DistributionListsHelper


  def index
    if params[:search].present?
      search = params[:search].downcase
      lists = DistributionList.where("LOWER(name) LIKE ? ", "%#{search}%")
    else
      lists = DistributionList.all
    end

    @lists = lists
  end

  def edit
  end

  def show
    set_list
    @members = @list.members
  end

  def send_message
    @list = DistributionList.find(params[:distribution_list_id])
    @members = @list.members
  end

  def send_list_new_message
    list = DistributionList.find(params[:distribution_list_id])
    message = params[:message]

    response = send_list_message(list, message )
    respond_to do |format|
      format.html { redirect_to list, notice: response }
      format.json { head :no_content }
    end
  end

  private

  def set_list
    @list = DistributionList.find(params[:id])
  end
end
