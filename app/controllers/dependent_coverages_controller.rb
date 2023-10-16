class DependentCoveragesController < ApplicationController
  before_action :set_dependent_coverage, only: %i[ show edit update destroy ]

  # GET /dependent_coverages or /dependent_coverages.json
  def index
    @dependent_coverages = DependentCoverage.all
  end

  # GET /dependent_coverages/1 or /dependent_coverages/1.json
  def show
  end

  # GET /dependent_coverages/new
  def new
    @dependent_coverage = DependentCoverage.new
  end

  # GET /dependent_coverages/1/edit
  def edit
  end

  # POST /dependent_coverages or /dependent_coverages.json
  def create
    @dependent_coverage = DependentCoverage.new(dependent_coverage_params)

    respond_to do |format|
      if @dependent_coverage.save
        format.html { redirect_to dependent_coverage_url(@dependent_coverage), notice: "Dependent coverage was successfully created." }
        format.json { render :show, status: :created, location: @dependent_coverage }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dependent_coverage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dependent_coverages/1 or /dependent_coverages/1.json
  def update
    respond_to do |format|
      if @dependent_coverage.update(dependent_coverage_params)
        format.html { redirect_to dependent_coverage_url(@dependent_coverage), notice: "Dependent coverage was successfully updated." }
        format.json { render :show, status: :ok, location: @dependent_coverage }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dependent_coverage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dependent_coverages/1 or /dependent_coverages/1.json
  def destroy
    @dependent_coverage.destroy

    respond_to do |format|
      format.html { redirect_to dependent_coverages_url, notice: "Dependent coverage was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dependent_coverage
      @dependent_coverage = DependentCoverage.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dependent_coverage_params
      params.require(:dependent_coverage).permit(:coverage_id, :dependent_id, :member_id, :term, :residency, :group_coverage, :group_premium)
    end
end
