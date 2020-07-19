class MembersController < ApplicationController
  def show
    set_member
  end

  def index
    if params[:search].present?
      search = params[:search].downcase
      @members = Member.where("first_name != ?", "")
              .where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(first_name || ' ' || last_name) LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%")
    else
      @members = Member.all
    end
  end

private

  def set_member
    @member = Member.find(params[:id])
  end

end
