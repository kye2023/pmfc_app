class CoveragesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_coverage, only: %i[ show edit update destroy sgyrt_submit lppi_submit ]
  

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
    @actvID = params[:activeID]
    @actvPlan = params[:plan]
    @actvAge = params[:age]
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
            verify_plan(@coverage)
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

  def verify_plan(arr)
    lppi_status = arr.member.plan_lppi
    sgyrt_status = arr.member.plan_sgyrt
    
    if lppi_status == true && sgyrt_status == true
      # return "dependent save"
      dependent_coverage_save
    elsif lppi_status == true && sgyrt_status == false
      # update/remove (group) records from coverage
      # return "LPPI (active)"
    elsif lppi_status == false && sgyrt_status == true  
      # update/remove (lppi) records from coverage
      # return "SGYRT (active)"
    end   
    
  end

  def dependent_coverage_save
    #Add record to dependent coverage
    @coverage.member.dependents.each do |dependent|
      dep_coverage = DependentCoverage.new
      dep_coverage.coverage_id = @coverage.id
      dep_coverage.dependent_id = dependent.id
      dep_coverage.member_id = @coverage.member_id

      dprel = dependent.relationship.strip

      gp = GroupPremium.where('? between residency_floor and residency_ceiling', @coverage.residency)
      dep_coverage.premium = gp.find_by(member_type: dprel, term: @coverage.term).premium unless gp.nil?

      gb = GroupBenefit.where('? between residency_floor and residency_ceiling', @coverage.residency)
      dep_coverage.group_benefit_id = gb.find_by(member_type: dprel).id
      
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
   @dplan = params[:plan]
   @dage = params[:age]
    # raise "errors"
    @coverage.destroy
    respond_to do |format|
      format.html { redirect_to batch_url(@batch, qry: @dage, pln: @dplan, pth: "b1"), notice: "Coverage was successfully destroyed." }
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

  def sgyrt_submit 
    @get_cvgId_ss = @coverage.id
    @acplan = params[:aplan]
    @acage = params[:aage]
    if @get_cvgId_ss.present?
      if @coverage.member.update(plan_sgyrt: 0)
        # Perform the delete operation
        @coverage.dependent_coverages.destroy_all # or use destroy_by if you have specific conditions
        respond_to do |format| 
          format.html { redirect_to batch_url(@batch, qry: @acage, pln: @acplan, pth: "b1"), notice: "Group successfully removed." }
        end
      else
        respond_to do |format| 
          format.html { redirect_to batch_url(@batch, qry: @acage, pln: @acplan, pth: "b1"), alert: "Unable to update member's plan." }
        end
      end
    else
      respond_to do |format| 
        format.html { redirect_to batch_url(@batch, qry: @acage, pln: @acplan, pth: "b1"), alert: "Unable to save, No loan(s) recorded." }
      end
    end
  end

  def lppi_submit
    @get_cvgId_ls = @coverage.id
    @acplan = params[:aplan]
    @acage = params[:aage]
    if @get_cvgId_ls.present?
      if @coverage.member.update(plan_lppi: 0)
        # @coverage.dependent_coverages.destroy_all
        respond_to do |format| 
          format.html { redirect_to batch_url(@batch, qry: @acage, pln: @acplan, pth: "b1"), notice: "Group successfully removed." }
        end
      else
        respond_to do |format| 
          format.html { redirect_to batch_url(@batch, qry: @acage, pln: @acplan, pth: "b1"), alert: "Unable to update member's plan." }
        end
      end
    else
      respond_to do |format| 
        format.html { redirect_to batch_url(@batch, qry: @acplan, pln: @acplan, pth: "b1"), alert: "Unable to save, No loan(s) recorded." }
      end
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
      params.require(:coverage).permit(:batch_id, :member_id, :loan_certificate, :age, :effectivity, :expiry, :term, :status, :loan_coverage, :lppi_gross_premium, :group_certificate, :residency, :group_coverage, :group_premium, :grace_period, :substandard_rate, :center_name_id)
    end

end
