class DistributionListsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_confirmed_by_admin?
  before_action :is_admin_or_higher

  include DistributionListsHelper


  def new
    @list = DistributionList.new
    @members = Member.all
  end

  def create
    @members = Member.all

    @list = DistributionList.new(list_params)
    respond_to do |format|
      if @list.save
        req = create_list(@list, @list.name) unless @list.threema_id
        format.html { redirect_to @list, notice: "Verteilerliste wurde erfolgreich erstellt" }
        format.json { render :show, status: :created, location: @list }
      else
        format.html { render :new }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    unless params[:per_page].present?
      params[:per_page] = 25 #default
    end

    if params[:search].present?
      search = params[:search].downcase
      lists = DistributionList.where("LOWER(name) LIKE ? ", "%#{search}%")
    else
      lists = DistributionList.all
    end

    @lists = lists.paginate(page: params[:page],  :per_page => params[:per_page])
  end

  def edit
    set_list
    @members = Member.all
    @categories = Member.all.map{| m | [m.category, m.category] if m.category != nil }.uniq.reject(&:nil?)
  end

  def update
    set_list
    req = update_list_attributes(@list, params[:distribution_list][:name])
    if req[1] == 204 || req[1] == 200 || @list.threema_id.nil?
      respond_to do |format|
        if @list.update(list_params)
          @list.reload
          update_recipients(@list) if @list.threema_id
          format.html { redirect_to @list, notice: "Die Liste wurde aktualisiert." }
          format.json { render :show, status: :ok, location: @list }
        else
          format.html { render :edit }
          format.json { render json: @list.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
          format.html { redirect_to @list, notice: "Fehler bei der Kommunikation mit Threema: #{req}\n Übermittelt: #{params[:distribution_list]}" }
          format.json { head :no_content }
      end
    end
  end


  def show
    set_list
    @members = @list.members
    @all_messages = get_list_chat(@list)

    if params[:show_all_messages].present?
      messages = @all_messages
    else
      messages = @all_messages.first(3)
    end
    @messages = messages
  end

  def send_message
    @list = DistributionList.find(params[:distribution_list_id])
    @members = @list.members
  end

  def send_list_new_message
    list = DistributionList.find(params[:distribution_list_id])
    message = params[:message]

    if params[:attachment]
      filename = params[:attachment].original_filename
      puts "File attached: #{filename}"

      decoded = params[:attachment].tempfile.open.read.force_encoding(Encoding::UTF_8)
      file = Base64.encode64(decoded)
    else
      file = nil
      filename = nil
    end

    response = send_list_message(list, message, file, filename)
    respond_to do |format|
      format.html { redirect_to list, notice: "Die Nachricht wurde versendet. Es kann einige Minuten dauern bis Nachricht angezeigt wird." }
      format.json { head :no_content }
    end
  end



  private

  def set_list
    @list = DistributionList.find(params[:id])
  end

  def list_params
    params.require(:distribution_list).permit(:name, :member_ids => [])
  end


end
