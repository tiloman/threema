class GroupsController < ApplicationController
before_action :authenticate_user!
before_action :user_confirmed_by_admin?
before_action :is_management_or_higher, only: [:group_requests, :create_group_in_threema]
before_action :set_group, only: [:edit, :update, :show, :destroy]
before_action :is_member_of_group, only: [:show]

include GroupsHelper
require "base64"

  def new
    @group = Group.new
    @members = Member.all
  end

  def create
    @members = Member.all

    @group = Group.new(group_params)
    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Gruppe wurde erfolgreich erstellt' }
        format.json { render :show, status: :created, location: @group }
        if current_user.is_management_or_higher
          create_group(@group, @group.name, @group.members.map { |m| m.threema_id }.to_a, @group.saveChatHistory) unless @group.threema_id
        else
          puts "---------------------------------------"
          User.owners.each do |owner|
            AdminMailer.new_group_request(current_user, @group, owner).deliver_later
          end
        end
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end


  def edit
    @members = Member.all
    @categories = Member.all.map{| m | [m.category, m.category] if m.category != nil }.uniq.reject(&:nil?)
  end

  def update
    req = update_group_attributes(@group, params[:group][:name], params[:group][:saveChatHistory])
    if req == 204 || @group.threema_id.nil?
      respond_to do |format|
        if @group.update(group_params)
          @group.reload
          update_members(@group) if @group.threema_id
          format.html { redirect_to @group, notice: "Die Gruppe wurde aktualisiert." }
          format.json { render :show, status: :ok, location: @group }
        else
          format.html { render :edit }
          format.json { render json: @group.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
          format.html { redirect_to @group, notice: "Fehler bei der Kommunikation mit Threema: #{req}\n Übermittelt: #{params[:group]}" }
          format.json { head :no_content }
      end
    end
  end

  def index
    unless params[:per_page].present?
      params[:per_page] = 25 #default
    end

    if current_user.is_management_or_higher
      groups = Group.all
    else
      member = Member.find_by(threema_id: current_user.threema_id)
      groups = member.groups if member
    end

    if params[:search].present?
      search = params[:search].downcase
      groups = groups.where("LOWER(name) LIKE ? ", "%#{search}%")
    else
      groups = groups
    end

    if params[:all_groups].present?
      groups = groups.include_deleted
    else
      groups = groups
    end

    @groups = groups.paginate(page: params[:page],  :per_page => params[:per_page])

  end


  def group_requests
    @groups = Group.local_groups.paginate(page: params[:page])
  end

  def show
    Member.sync_members_of_group(@group)
    @threema_members = get_members_from_server(@group) if @group.threema_id
    @members = @group.members
    @string = Base64.encode64(open("https:#{@group.avatar.url(:medium)}") { |io| io.read })

  end

  def create_group_in_threema
    @group = Group.find(params[:group_id])
    create_group(@group, @group.name, @group.members.map { |m| m.threema_id }.to_a, @group.saveChatHistory) unless @group.threema_id
  end


  def destroy
    if req = delete_group_from_threema(@group) == "204" || @group.threema_id.nil?
      if @group.destroy
        respond_to do |format|
          format.html { redirect_to groups_url, notice: 'Gruppe wurde gelöscht.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { render :show }
          format.json { render json: @group.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
          format.html { redirect_to groups_url, notice: "Fehler: #{req}" }
          format.json { head :no_content }
      end
    end
  end


  private

    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:name, :saveChatHistory, :avatar, :member_ids => [])
    end

    def is_member_of_group
      member = Member.find_by(threema_id: current_user.threema_id)
      redirect_to groups_path, notice: "Keine Berechtigung." unless @group.members.exists?(member.id) || current_user.is_management_or_higher
    end

end
