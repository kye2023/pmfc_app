class DependentsController < ApplicationController
  before_action :set_dependent, only: %i[ show edit update destroy ]

  # GET /dependents or /dependents.json
  def index
    if params[:query].present?
      @dependents = Dependent.where("last_name LIKE ?", "%#{params[:query]}%")
    else
      @dependents = Dependent.all
    end
  end

  # GET /dependents/1 or /dependents/1.json
  def show
  end

  # GET /dependents/new
  def new
    #@dependent = Dependent.new
    #pass member id parameter @ dependents
    @member = Member.find(params[:m])
    @dependent = @member.dependents.build
  end

  # GET /dependents/1/edit
  def edit
  end

  # POST /dependents or /dependents.json
  def create
    #@dependent = Dependent.new(dependent_params)
    @member = Member.find(params[:m])
    @dependent = @member.dependents.build(dependent_params)

    respond_to do |format|
      if @dependent.save
        format.html { redirect_to @member, notice: "Dependent was successfully created." }
        format.json { render :show, status: :created, location: @dependent }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dependent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dependents/1 or /dependents/1.json
  def update
    respond_to do |format|
      if @dependent.update(dependent_params)
        format.html { redirect_to @member, notice: "Dependent was successfully updated." }
        format.json { render :show, status: :ok, location: @dependent }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dependent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dependents/1 or /dependents/1.json
  def destroy
    @dependent.destroy

    respond_to do |format|
      format.html { redirect_to dependents_url, notice: "Dependent was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dependent
      @dependent = Dependent.find(params[:id])
      @member = @dependent.member
    end

    # Only allow a list of trusted parameters through.
    def dependent_params
      params.require(:dependent).permit(:member_id, :last_name, :first_name, :middle_name, :birth_date, :civil_status, :gender, :mobile_no, :email, :relationship)
    end
end
