class MembersController < ApplicationController
  before_action :authenticate_user!


  def show
    set_member
  end

  def index
    if params[:search]
      search = params[:search].downcase
      category = params[:category]
      @members = Member
              .where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(first_name || ' ' || last_name) LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%")

    else
      @members = Member.all
    end

    if params[:category].present?
      @members = @members.where("category LIKE ?", params[:category])
    end

    @categories = Member.all.map{| m | [m.category, m.category] if m.category != nil }.uniq.reject(&:nil?)

  end

private

  def set_member
    @member = Member.find(params[:id])
  end

end
