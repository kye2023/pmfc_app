class BatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_batch, only: %i[ show edit update destroy import_cov batch_submit]
  require 'csv'
  def batch_submit 
    @batch.update(submit: 1)
    respond_to do |format| 
      format.html { redirect_to batch_url(@batch), notice: "Batch was successfully submitted." }
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
