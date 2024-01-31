class BatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_batch, only: %i[ show edit update destroy import_cov batch_submit batch_preview]
  require 'csv'
  
  def batch_submit 
    @batch.update(submit: 1)
    respond_to do |format| 
      format.html { redirect_to batch_url(@batch, qry: 0, pln: 0, pth: "b1"), notice: "Batch was successfully submitted." }
    end
  end
  
  # GET /batches or /batches.json
  def index
    if current_user.admin == true
      @batches = Batch.all
    else
      @batches = Batch.where(branch_id: current_user.user_detail.branch_id)
    end
   

    respond_to do |format|
      format.html
      format.csv do 
        send_data Batch.to_csv, filename: Date.today.to_s, content_type: 'text/csv'
      end
    end

  end

  # GET /batches/1 or /batches/1.json
  def show
    age = params[:qry]
    plan = params[:pln]
    path = params[:bth]

    case age
    when "1865"
      @show_coverage = @batch.coverages.where(age: 18..65)
    when "6670b"
      @show_coverage = @batch.coverages.where(age: 66..70).where("loan_coverage <= 350000")
    when "6670a"
      @show_coverage = @batch.coverages.where(age: 66..70).where("loan_coverage > 350001")
    when "7175b"
      @show_coverage = @batch.coverages.where(age: 71..75).where("loan_coverage <= 350000")
    when "7175a"
      @show_coverage = @batch.coverages.where(age: 71..75).where("loan_coverage > 350001")
    when "7680b"
      @show_coverage = @batch.coverages.where(age: 76..80).where("loan_coverage <= 350000")
    when "7680a"
      @show_coverage = @batch.coverages.where(age: 76..80).where("loan_coverage > 350001")
    else
      @show_coverage = @batch.coverages
    end

    #search bar
    # if params[:query].present?
    #   @show_coverage = @show_coverage.joins(:member).where("members.last_name LIKE ? OR members.first_name LIKE ?", "#{params[:query]}", "#{params[:query]}")
    # else
    #   @show_coverage
    # end
    
    @pagy, @records = pagy(@show_coverage, items: 5)

    #download CSV
    respond_to do |format|
      format.html
      format.csv do 
        send_data @batch.batch_csv(@batch.id), filename: "#{@batch.title}-" + "#{@batch.branch.name}-" + Date.today.to_s, content_type: 'text/csv'
      end
    end
    # raise "errors"
   
  end

  # GET /batches/new
  def new
    @batch = Batch.new
  end

  def import_cov
  end

  # GET /batches/1/edit
  def edit
  end

  # POST /batches or /batches.json
  def create
    @batch = Batch.new(batch_params)

    respond_to do |format|
      if @batch.save
        format.html { redirect_to batch_url(@batch, qry: 0, pln: 0, pth: "b1"), notice: "Batch was successfully created." }
        format.json { render :show, status: :created, location: @batch }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batches/1 or /batches/1.json
  def update
    respond_to do |format|
      if @batch.update(batch_params)
        format.html { redirect_to batch_url(@batch, qry: 0, pln: 0, pth: "b1"), notice: "Batch was successfully updated." }
        format.json { render :show, status: :ok, location: @batch }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batches/1 or /batches/1.json
  def destroy
    @batch.destroy

    respond_to do |format|
      format.html { redirect_to batches_url, notice: "Batch was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def import
    batch_id = params[:id]

    import_service = ImportService.new(:batch,params[:file],batch_id)
    import_message = import_service.import
    redirect_to batches_path, notice: import_message
  end

  def import_coverages
    # batch_id = @batch.id
    # import_service = ImportService.new(:coverage, params[:file], batch_id)
    # import_message = import_service.import
    # redirect_to batches_path, notice: import_message
  end

  def batch_download
    
  end

  def batch_preview

    #Initialize PDF
    pdf = Prawn::Document.new
    pdf.image "#{Prawn::DATADIR}/pmfc.png", scale: 0.15
    pdf.text "PEOPLE'S MICRO FINANCE COOPERATIVE"
    pdf.move_down 20

    data_zero = [ ["#{"Title :"+@batch.title+"\n Branch :"+@batch.branch.name+"\n Description :"+@batch.description}"] ]
    pdf.table(data_zero, :cell_style => { :font => "Times-Roman", :size => 12}, :width => 540 )
    pdf.move_down 20

    #THeader
    data_one = [["#","Certificate", "Name", "Coverage", "Effectiity", "Expiry", "Term","Premium"]]
    
    #TBody Active Record
    total_prem = 0
    @batch.coverages.each do |c|
      count_dpnt = c.dependent_coverages.count(:id).to_s
      s_age = c.age.to_s
      s_rcdncy=c.residency.to_s
     
      loan_prem = c.loan_premium
      dependent_prem = c.dependent_coverages.sum(:premium)
      group_prem = c.group_premium

      data_one +=[
          ["#{c.id}",
          "#{c.group_certificate}",
          "#{c.member.get_cmember+" ("+c.coverage_status+")"+"\n"+helpers.to_shortdate(c.member.birth_date)+" | "+s_age+" y/o \n\n"+"Residency: "+s_rcdncy+"\n Dependent(s): "+count_dpnt}",
          "#{"Loan: "+helpers.to_curr(c.loan_coverage)+"\n\n L: "+helpers.to_curr(c.group_benefit.life)+"\n AD :"+helpers.to_curr(c.group_benefit.add)+"\n B :"+helpers.to_curr(c.group_benefit.burial) }",
          "#{helpers.to_shortdate(c.effectivity)}",
          "#{helpers.to_shortdate(c.expiry)}",
          "#{c.term}",
          "#{helpers.to_curr(loan_prem+dependent_prem+group_prem)}"
          ]
        ]
        total_prem += loan_prem+dependent_prem+group_prem
    end  
    
    data_one +=[[{:content => "Total Premium :", :colspan => 7, align: :right },"#{helpers.to_curr(total_prem)}"]]

    #Table Format
    pdf.table(data_one, :cell_style => { :font => "Times-Roman", :size => 10 }, :row_colors => ["F0F0F0", "FFFFCC"] ) do
      rows(0).border_width = 2
      columns(2).width = 150
      columns(3).width = 100
    end  

    #Render PDF
    send_data(pdf.render,
        filename: 'hello.pdf', 
        type: 'application/pdf', 
        disposition: 'inline')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_batch
      @batch = Batch.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def batch_params
      params.require(:batch).permit(:title, :description, :branch_id)
    end
end
