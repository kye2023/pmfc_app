class GroupBenefitsController < ApplicationController
  before_action :set_group_benefit, only: %i[ show edit update destroy ]

  # GET /group_benefits or /group_benefits.json
  def index
    @group_benefits = GroupBenefit.all
  end

  # GET /group_benefits/1 or /group_benefits/1.json
  def show
  end

  # GET /group_benefits/new
  def new
    @group_benefit = GroupBenefit.new
  end

  # GET /group_benefits/1/edit
  def edit
  end

  # POST /group_benefits or /group_benefits.json
  def create
    @group_benefit = GroupBenefit.new(group_benefit_params)

    respond_to do |format|
      if @group_benefit.save
        format.html { redirect_to group_benefit_url(@group_benefit), notice: "Group benefit was successfully created." }
        format.json { render :show, status: :created, location: @group_benefit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group_benefit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /group_benefits/1 or /group_benefits/1.json
  def update
    respond_to do |format|
      if @group_benefit.update(group_benefit_params)
        format.html { redirect_to group_benefit_url(@group_benefit), notice: "Group benefit was successfully updated." }
        format.json { render :show, status: :ok, location: @group_benefit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group_benefit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group_benefits/1 or /group_benefits/1.json
  def destroy
    @group_benefit.destroy

    respond_to do |format|
      format.html { redirect_to group_benefits_url, notice: "Group benefit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group_benefit
      @group_benefit = GroupBenefit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_benefit_params
      params.require(:group_benefit).permit(:benefit_id, :residency_from, :residency_to, :relationship, :amount_benefit)
    end
end
