class GroupsController < ApplicationController
before_action :authenticate_user!

  include GroupsHelper


  def new
    @group = Group.new
  end

  def create
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

  def manage
  end

  def edit
    set_group
  end

  def update
    set_group
    if req = update_group_attributes(@group, params[:group][:name], false).status == 204
      respond_to do |format|
        if @group.update(group_params)
          @group.reload
          update_members(@group)
          format.html { redirect_to @group, notice: "Die Gruppe wurde aktualisiert.#{req}" }
          format.json { render :show, status: :ok, location: @group }
        else
          format.html { render :edit }
          format.json { render json: @group.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
          format.html { redirect_to groups_url, notice: "Fehler: #{update_group_attributes(@group, name = "rails-testgruppe", saveChatHistory = false) }" }
          format.json { head :no_content }
      end
    end
  end

  def index
    if params[:search].present?
      search = params[:search].downcase
      @groups = Group
              .where("LOWER(name) LIKE ? ", "%#{search}%")
              .paginate(:page => params[:page], :per_page => params[:per_page])
    else
      @groups = Group.all.where(state: "active")
                .paginate(page: params[:page])

    end

    @not_synced_groups = Group.all.where(threema_id: [nil, ""])
            .paginate(page: params[:page])


  end

  def show
    set_group
    if params[:sync].present?
      update_members(@group)
    end

    if params[:create_group].present?
      create_group(@group.name, @group.members.map { |m| m.threema_id }, false)
    end

    @members = get_members_from_server(@group) if @group.threema_id

  end

    def destroy
      set_group
      if req = delete_group_from_threema(@group) == "204"
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
      params.require(:group).permit(:name, :member_ids => [])
    end

end
