class CenterNamesController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_center_name, only: %i[ show edit update destroy ]

  # GET /center_names or /center_names.json
  def index
    # @center_names = CenterName.all
    @center_names = CenterName.get_cname_index(current_user.admin, params[:query], current_user)
  end

  # GET /center_names/1 or /center_names/1.json
  def show
  
  end

  # GET /center_names/new
  def new
    @center_name = CenterName.new
  end

  # GET /center_names/1/edit
  def edit
  end

  # POST /center_names or /center_names.json
  def create
    @center_name = CenterName.new(center_name_params)

    respond_to do |format|
      if @center_name.save
        format.html { redirect_to center_name_url(@center_name), notice: "Center name was successfully created." }
        format.json { render :index, status: :created, location: @center_name }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @center_name.errors, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /center_names/1 or /center_names/1.json
  def update
    respond_to do |format|
      if @center_name.update(center_name_params)
        format.html { redirect_to center_name_url(@center_name), notice: "Center name was successfully updated." }
        format.json { render :show, status: :ok, location: @center_name }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @center_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /center_names/1 or /center_names/1.json
  def destroy
    @center_name.destroy

    respond_to do |format|
      format.html { redirect_to center_names_url, notice: "Center name was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def load_center
    @center_names = CenterName.all
    render json: @center_names
  end

  def find_center
    @cntr_name = params[:cname]
    @ccenters = CenterName.where(description: @cntr_name)
    # raise "errors"
    render json: @ccenters
  end

  def add_new_center
    @branchID = params[:cbranch]
    @cntrname = params[:cname]
    @ctarget = params[:target]
      
    @find_cname = CenterName.find_or_initialize_by(description: @cntrname, branch_id: @branchID)
   
    if @find_cname.persisted? == false
      @find_cname.save
      @load_cnames = CenterName.all
      render turbo_stream: [ turbo_stream.update(@ctarget, partial: "center_names/load_cselect", locals: { lCname: @load_cnames }) ]
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_center_name
      @center_name = CenterName.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def center_name_params
      params.require(:center_name).permit(:description, :branch_id)
    end
end
