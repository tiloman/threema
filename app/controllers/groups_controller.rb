class GroupsController < ApplicationController
before_action :authenticate_user!

include GroupsHelper

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
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end


  def edit
    set_group
    @members = Member.all
    @categories = Member.all.map{| m | [m.category, m.category] if m.category != nil }.uniq.reject(&:nil?)

  end

  def update
    set_group
    req = update_group_attributes(@group, params[:group][:name], params[:group][:saveChatHistory])
    if req.status == 204 || @group.threema_id.nil?
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
          format.html { redirect_to @group, notice: "Fehler bei der Kommunikation mit Threema: #{req.body}\n Übermittelt: #{params[:group]}" }
          format.json { head :no_content }
      end
    end
  end

  def index
    unless params[:per_page].present?
      params[:per_page] = 25 #default
    end


    if params[:search].present?
      search = params[:search].downcase
      groups = Group.where("LOWER(name) LIKE ? ", "%#{search}%")
    else
      groups = Group.all
    end

    if params[:all_groups].present?
      groups = groups.where(state: ['active', 'deleted'])
    else
      groups = groups.where(state: "active")
    end

    @groups = groups.paginate(page: params[:page],  :per_page => params[:per_page])

  end

  def my_groups
    member = Member.find_by(threema_id: current_user.threema_id)
    @groups = member.groups
  end

  def group_requests
    @groups = Group.all.where(threema_id: [nil, ""])
                         .paginate(page: params[:page])
  end

  def show
    set_group
    Member.sync_members_of_group(@group)
    @threema_members = get_members_from_server(@group) if @group.threema_id
    @members = @group.members

  end

  def create_group_in_threema
    @group = Group.find(params[:group_id])
    create_group(@group, @group.name, @group.members.map { |m| m.threema_id }.to_a, @group.saveChatHistory) unless @group.threema_id
  end


    def destroy
      set_group
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
      params.require(:group).permit(:name, :saveChatHistory, :member_ids => [])
    end

end
