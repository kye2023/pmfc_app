class CoveragesController < ApplicationController
  # before_action :authenticate_user!
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
    # @coverage = Coverage.new
    @batch = Batch.find(params[:b])
    @coverage = @batch.coverages.build
    dummy_data
  end

  def dummy_data 
    @coverage.loan_certificate = rand(100000..999999)
    @coverage.group_certificate = rand(100000..999999)
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
      #@coverage = Coverage.new(coverage_params)
      
      @batch = Batch.find(params[:b])
      @coverage = @batch.coverages.build(coverage_params)
      
      #@coverage.compute_age(@member.birth_date,coverage_params[:effectivity])
      #@coverage.coverage_aging(coverage_params[:effectivity],coverage_params[:expiry])
      #@member = Member.find(coverage_params[:member_id])
      #@member = Member.find(coverage_params[:member_id])
      
      @coverage.compute_age

      #@coverage.term = @coverage.coverage_aging
      #@coverage.lppi_gross_premium = @coverage.coverage_lppi_premium
      
      respond_to do |format|
      if @coverage.save
        dependent_coverage_save
        format.html { redirect_to @batch, notice: "Coverage was successfully created." }
        format.json { render :show, status: :created, location: @coverage }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @coverage.errors, status: :unprocessable_entity }
      end
    end
  end

  def dependent_coverage_save
    #Add record to dependent coverage
    @coverage.member.dependents.each do |dependent|
      dep_coverage = DependentCoverage.new
      dep_coverage.coverage_id = @coverage.id
      dep_coverage.dependent_id = dependent.id
      dep_coverage.member_id = @coverage.member_id
      
      #search data from group benefit
      #dependent.compute_dependent_benefit(@coverage)

      dep_coverage.group_benefit_id = dependent.compute_dependent_benefit(@coverage, "gb")
      dep_coverage.premium = dependent.compute_dependent_benefit(@coverage, "gp")
      
      unless dep_coverage.blank?
        dep_coverage.save!
      end

      
    end

  end

  # PATCH/PUT /coverages/1 or /coverages/1.json
  def update

    # @coverage.age = @coverage.compute_age 
    # @coverage.term = @coverage.coverage_aging
    # @coverage.lppi_gross_premium = @coverage.coverage_lppi_premium
    @coverage.compute_age
    respond_to do |format|
      if @coverage.update(coverage_params)
        format.html { redirect_to @batch, notice: "Coverage was successfully updated." }
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
    #@coverage.dependent_coverage.destroy
    respond_to do |format|
      format.html { redirect_to @batch, notice: "Coverage was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coverage
      @coverage = Coverage.find(params[:id])
      @batch = @coverage.batch
    end

    # Only allow a list of trusted parameters through.
    def coverage_params
      params.require(:coverage).permit(:batch_id, :member_id, :loan_certificate, :age, :effectivity, :expiry, :term, :status, :loan_coverage, :lppi_gross_premium, :group_certificate, :residency, :group_coverage, :group_premium)
    end

end
