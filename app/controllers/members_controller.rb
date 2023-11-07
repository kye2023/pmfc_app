class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_member, only: %i[ show edit update destroy ]

  # GET /members or /members.json
  def index
    require 'pagy/extras/bootstrap'
    
    if params[:query].present?
      @members = Member.where("last_name LIKE ?", "%#{params[:query]}%")
    else
      @members = Member.all
    end

    #set pagination
    @pagy, @members = pagy(@members, items: 10)
  end

  # GET /members/1 or /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
    if Rails.env.development?
      dummy_data
    end
  end

  def dummy_data 
    @member.last_name = FFaker::Name.last_name
    @member.first_name = FFaker::Name.first_name
    @member.middle_name = FFaker::Name.first_name[0]
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members or /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to member_url(@member), notice: "Member was successfully created." }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @member.errors, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1 or /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to member_url(@member), notice: "Member was successfully updated." }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1 or /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: "Member was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def import
    import_service = ImportService.new(:member, params[:file])
    import_message = import_service.import
    redirect_to members_path, notice: import_message
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def member_params
      params.require(:member).permit(:last_name, :first_name, :middle_name, :birth_date, :date_membership, :civil_status, :gender, :mobile_no, :email, dependents_attributes: [:id, :member_id, :last_name, :first_name, :middle_name, :birth_date, :relationship, :_destroy] )
    end

end
