class GroupPremiaController < ApplicationController
  before_action :set_group_premium, only: %i[ show edit update destroy ]

  # GET /group_premia or /group_premia.json
  def index
    @group_premia = GroupPremium.order(:term).all
    @grouped_gp = @group_premia.group_by(&:member_type)
  end

  # GET /group_premia/1 or /group_premia/1.json
  def show
  end

  # GET /group_premia/new
  def new
    @group_premium = GroupPremium.new
  end

  # GET /group_premia/1/edit
  def edit
  end

  # POST /group_premia or /group_premia.json
  def create
    @group_premium = GroupPremium.new(group_premium_params)

    respond_to do |format|
      if @group_premium.save
        format.html { redirect_to group_premium_url(@group_premium), notice: "Group premium was successfully created." }
        format.json { render :show, status: :created, location: @group_premium }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group_premium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /group_premia/1 or /group_premia/1.json
  def update
    respond_to do |format|
      if @group_premium.update(group_premium_params)
        format.html { redirect_to group_premium_url(@group_premium), notice: "Group premium was successfully updated." }
        format.json { render :show, status: :ok, location: @group_premium }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group_premium.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group_premia/1 or /group_premia/1.json
  def destroy
    @group_premium.destroy

    respond_to do |format|
      format.html { redirect_to group_premia_url, notice: "Group premium was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group_premium
      @group_premium = GroupPremium.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_premium_params
      params.require(:group_premium).permit(:member_type, :term, :residency_floor, :residency_ceiling, :premium)
    end
end
