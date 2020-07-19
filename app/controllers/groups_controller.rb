class GroupsController < ApplicationController
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
    if @group.update_group_attributes == 204
      respond_to do |format|
        if @group.update(group_params)
          format.html { redirect_to groups_url, notice: 'Die Gruppe wurde aktualisiert.' }
          format.json { render :show, status: :ok, location: @group }
        else
          format.html { render :edit }
          format.json { render json: @group.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
          format.html { redirect_to groups_url, notice: "Fehler: #{@group.update_group_attributes}" }
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
      Member.sync_members_of_group(@group)
    end

    if params[:image].present?
      @group.get_image
    end
    @members = @group.get_members_from_server if @group.threema_id
  end

    def destroy
      set_group
      if @group.delete_from_threema == "204"
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
            format.html { redirect_to groups_url, notice: "Fehler: #{@group.delete_from_threema}" }
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
