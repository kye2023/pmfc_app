class BenefitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_benefit, only: %i[ show edit update destroy ]

  # GET /benefits or /benefits.json
  def index
    @benefits = Benefit.all
  end

  # GET /benefits/1 or /benefits/1.json
  def show
  end

  # GET /benefits/new
  def new
    @benefit = Benefit.new
  end

  # GET /benefits/1/edit
  def edit
  end

  # POST /benefits or /benefits.json
  def create
    @benefit = Benefit.new(benefit_params)

    respond_to do |format|
      if @benefit.save
        format.html { redirect_to benefit_url(@benefit), notice: "Benefit was successfully created." }
        format.json { render :show, status: :created, location: @benefit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @benefit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /benefits/1 or /benefits/1.json
  def update
    respond_to do |format|
      if @benefit.update(benefit_params)
        format.html { redirect_to benefit_url(@benefit), notice: "Benefit was successfully updated." }
        format.json { render :show, status: :ok, location: @benefit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @benefit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /benefits/1 or /benefits/1.json
  def destroy
    @benefit.destroy

    respond_to do |format|
      format.html { redirect_to benefits_url, notice: "Benefit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_benefit
      @benefit = Benefit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def benefit_params
      params.require(:benefit).permit(:name, :description)
    end
end
