class CoveragesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_coverage, only: %i[ show edit update destroy ]
  

  # GET /coverages or /coverages.json
  def index
    @coverages = Coverage.all
  end

  # GET /coverages/1 or /coverages/1.json
  def show
  end
  
  # GET /coverages/new
  def new
    @coverage = Coverage.new
  end

  # GET /coverages/1/edit
  def edit
  end

  def selected
    # @target = params[:target]
    # @members = Member.where(id: params[:id])
    # respond_to do |format|
    # format.turbo_stream
    # end
  end

  # POST /coverages or /coverages.json
  def create
      @coverage = Coverage.new(coverage_params)
      
      #@coverage.compute_age(@member.birth_date,coverage_params[:effectivity])
      #@coverage.coverage_aging(coverage_params[:effectivity],coverage_params[:expiry])
      #@member = Member.find(coverage_params[:member_id])
      #@member = Member.find(coverage_params[:member_id])
      
      @coverage.age = @coverage.compute_age 
      @coverage.term = @coverage.coverage_aging
      @coverage.lppi_gross_premium = @coverage.coverage_lppi_premium
      
      respond_to do |format|
      if @coverage.save
        format.html { redirect_to coverage_url(@coverage), notice: "Coverage was successfully created." }
        format.json { render :show, status: :created, location: @coverage }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @coverage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /coverages/1 or /coverages/1.json
  def update

    # @coverage.age = @coverage.compute_age 
    # @coverage.term = @coverage.coverage_aging
    # @coverage.lppi_gross_premium = @coverage.coverage_lppi_premium

    respond_to do |format|
      if @coverage.update(coverage_params)
        format.html { redirect_to coverage_url(@coverage), notice: "Coverage was successfully updated." }
        format.json { render :show, status: :ok, location: @coverage }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @coverage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /coverages/1 or /coverages/1.json
  def destroy
    @coverage.destroy

    respond_to do |format|
      format.html { redirect_to coverages_url, notice: "Coverage was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coverage
      @coverage = Coverage.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def coverage_params
      params.require(:coverage).permit(:batch_id, :member_id, :loan_certificate, :age, :effectivity, :expiry, :term, :status, :lppi_gross_coverage, :lppi_gross_premium, :group_certificate, :residency, :group_coverage, :group_premium)
    end

end
