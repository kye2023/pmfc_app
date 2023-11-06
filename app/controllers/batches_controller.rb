class BatchesController < ApplicationController
  before_action :set_batch, only: %i[ show edit update destroy import_cov]

  # GET /batches or /batches.json
  def index
    @batches = Batch.all
  end

  # GET /batches/1 or /batches/1.json
  def show
    # raise 'errors'
    case params[:s]
    when "1"
      @show_coverage = @batch.coverages.where(age: 18..40)
    # when "0"
    else
      @show_coverage = @batch.coverages
    end
    @pagy, @records = pagy(@show_coverage, items: 5)

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
        format.html { redirect_to batch_url(@batch), notice: "Batch was successfully created." }
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
        format.html { redirect_to batch_url(@batch), notice: "Batch was successfully updated." }
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
    # raise 'errors'
    batch_id = params[:p]
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
