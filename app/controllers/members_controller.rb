class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :user_confirmed_by_admin?


  def show
    set_member
  end

  def index
    unless params[:per_page].present?
      params[:per_page] = 25 #default
    end

    if params[:search]
      search = params[:search].downcase
      category = params[:category]
      members = Member
              .where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(first_name || ' ' || last_name) LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%")

    else
      members = Member.all
    end

    if params[:category].present?
      members = members.where("category LIKE ?", params[:category])
    end
    @members = members.paginate(page: params[:page],  :per_page => params[:per_page])

    @categories = Member.all.map{| m | [m.category, m.category] if m.category != nil }.uniq.reject(&:nil?)

  end

private

  def set_member
    @member = Member.find(params[:id])
  end

end
