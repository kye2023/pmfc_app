class CoveragesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_coverage, only: %i[ show edit update destroy ]
  

  # GET /coverages or /coverages.json
  def index

    require 'pagy/extras/bootstrap'
    
    # @ccoverages = Coverage.all
    @coverages = Coverage.get_coverages_index(current_user.admin, params[:query], current_user)
    # raise "errors"

   
    if params[:query].present? == true
      @cntcvg = Coverage.get_coverages_index(current_user.admin, params[:query]=nil, current_user)
    else
      @cntcvg = @coverages
    end

    @cn_exp_cvg = 0
    @cn_act_cvg = 0
    
    @cntcvg.each do |ccvg|
      
      chk_cvg = Coverage.where(member_id: ccvg.member_id)
      ret_cvg = chk_cvg.order(:effectivity,:expiry).last
      cov_aging = ret_cvg.coverage_aging

      cn_aging = cov_aging
      if cn_aging <= 0
        @cn_exp_cvg += 1
      elsif
        @cn_act_cvg += 1  
      end
    end

    #set pagination 
    @pagy, @coverages = pagy(@coverages, items: 25)

  end

  # GET /coverages/1 or /coverages/1.json
  def show
  end
  
  # GET /coverages/new
  def new
    ###@coverage = Coverage.new
    # @batch = Batch.find(params[:b])
    # @coverage = @batch.coverages.build

    @bId = params[:b]
    @cId = params[:c]
    @mId = params[:m]

    if @bId.present? == true
      @batch = Batch.find(params[:b])
      @coverage = @batch.coverages.build
    elsif @mId.present? == true
      @member = Member.find(params[:m])
      @coverage = @member.coverages.build
      chk_cvg = Coverage.where(id: @cId)
      ret_cvg = chk_cvg.order(:effectivity,:expiry).last
      @get_cvg_sts = ret_cvg.status
    end

    # raise "errors"

    dummy_data
  end

  def dummy_data 
    @coverage.loan_certificate = rand(100000..999999)
    @coverage.group_certificate = rand(100000..999999)
    @coverage.effectivity = Date.current
  end

  # GET /coverages/1/edit
  def edit
  end

  def selected
    # @members = Member.where(id: params[:id])
    @target = params[:categoryId]
    respond_to do |format|
    format.turbo_stream
    # format.json { render json: @coverage.errors, status: :unprocessable_entity }
    end
  end

  # POST /coverages or /coverages.json
  def create
    if params[:b].present? == true
      @batch = Batch.find(params[:b])
      @coverage = @batch.coverages.build(coverage_params)
    elsif params[:m].present? == true
      @member = Member.find(params[:m])
      @coverage = @member.coverages.build(coverage_params)
    end

    if params[:memberBtn]
      # form->member Button
      # @batch = Batch.find(params[:b])
      # @coverage = @batch.coverages.build(coverage_params)
      # raise "error"
      if @coverage.valid?
        @coverage.compute_age
        respond_to do |format|
          if @coverage.save
            dependent_coverage_save
            #format.html { redirect_to @batch, notice: "Coverage was successfully created." }
            if @member.present? == true  
              format.html { redirect_to batch_url(@coverage.batch_id, qry: 0, pln: 0, pth: "b1"), notice: "Coverage was successfully created." }
            else    
              format.html { redirect_to batch_url(@batch, qry: 0, pln: 0, pth: "b1"), notice: "Coverage was successfully created." }
            end
            format.json { render :show, status: :created, location: @coverage }
          else
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @coverage.errors, status: :unprocessable_entity }
            format.turbo_stream { render :form_update, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @coverage.errors, status: :unprocessable_entity }
          format.turbo_stream { render :form_update, status: :unprocessable_entity }
        end
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
      
      #dep_coverage.batch_id = @coverage.batch_id
      #search data from group benefit
      #dependent.compute_dependent_benefit(@coverage)
      
      gp = GroupPremium.where('? between residency_floor and residency_ceiling', @coverage.residency)
      dep_coverage.premium = gp.find_by(member_type: dependent.relationship, term: @coverage.term).premium unless gp.nil?

      gb = GroupBenefit.where('? between residency_floor and residency_ceiling', @coverage.residency)
      dep_coverage.group_benefit_id = gb.find_by(member_type: dependent.relationship).id
      
      # dep_coverage.group_benefit_id = dependent.compute_dependent_benefit(@coverage, "gb")
      # dep_coverage.premium = dependent.compute_dependent_benefit(@coverage, "gp")
      
      dep_coverage.save!
     
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
        format.html { redirect_to batch_url(@batch, qry: 0, pln: 0, pth: "b1"), notice: "Coverage was successfully updated." }
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
      format.html { redirect_to batch_url(@batch, qry: 0, pln: 0, pth: "b1"), notice: "Coverage was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def check_residency
    @mmbrID = params[:Id]
    
    @check_coverage = Coverage.where(member_id: @mmbrID)
    
    if @check_coverage.empty? == true
        render json: {
          mmbrID: @mmbrID,
          residency: 0,
          status: 0,
          count_id: 0,
          coverage: 0,
          redirecto: member_path(@mmbrID)
        }
    else
      @count_coverage = @check_coverage.where(member_id: @mmbrID).count
      @sum_residency = @check_coverage.sum(:term)
    
      # Sort record base on terms and retrieve the latest record (1 record)
      @retrieve_coverage = @check_coverage.order(:effectivity,:expiry).last
      @cov_aging = @retrieve_coverage.coverage_aging

      @cov_status = @retrieve_coverage.status
      @member_link = member_path(@mmbrID)

      render json: { 
        mmbrID: @mmbrID, 
        residency: @sum_residency, 
        status: @cov_status, 
        count_id: @count_coverage, 
        coverage: @cov_aging, 
        redirecto: @member_link 
      }
       
    end
    
  end

  def coverage_history
    
    @target = params[:target]
    @chkCoverage = Coverage.where(member_id: params[:Id])
    # raise "errors"

    if @chkCoverage.empty? == true
      render turbo_stream: [ turbo_stream.update(@target, partial: "coverages/show_prev_loan", locals: { rCvg: nil }) ]
    else
      @rtrCoverage = @chkCoverage.order(:effectivity, :expiry).last
      # format.turbo_stream show output to "coverage_history.turbo_stream.erb"
      render turbo_stream: [ turbo_stream.update(@target, partial: "coverages/show_prev_loan", locals: { rCvg: @rtrCoverage }) ]
    end

  end

  def coverage_premium_benefits
    @ptarget = params[:ptarget]
    @pId = params[:Id]
    @eDate = params[:efdate]
    @pterm = params[:term]
    @rsdncy = params[:residency]
    @pgp = params[:gperiod]
    @ploans = params[:loans]

    # @getMember = Member.find(@pId)
    @coveragePremiumBenefits = Coverage.new(member_id: @pId, effectivity: @eDate, term: @pterm, residency: @rsdncy, grace_period: @pgp, loan_coverage: @ploans)
    @coveragePremiumBenefits.compute_age
    # raise "error"

    render turbo_stream: [ turbo_stream.update(@ptarget, partial: "coverages/show_premium", locals: { sCvg: @coveragePremiumBenefits }) ]

  end

  def renewal
    
    # @coverages = Coverage.all
    @coverages = Coverage.get_coverages_index(current_user.admin, params[:query], current_user)
   
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coverage
      @coverage = Coverage.find(params[:id])
      @batch = @coverage.batch
    end

    # Only allow a list of trusted parameters through.
    def coverage_params
      params.require(:coverage).permit(:batch_id, :member_id, :loan_certificate, :age, :effectivity, :expiry, :term, :status, :loan_coverage, :lppi_gross_premium, :group_certificate, :residency, :group_coverage, :group_premium, :grace_period, :substandard_rate, :center_name_id)
    end

end
