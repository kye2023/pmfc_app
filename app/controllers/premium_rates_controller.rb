class PremiumRatesController < ApplicationController
  before_action :set_premium_rate, only: %i[ show edit update destroy ]

  # GET /premium_rates or /premium_rates.json
  def index
    @premium_rates = PremiumRate.all
  end

  # GET /premium_rates/1 or /premium_rates/1.json
  def show
  end

  # GET /premium_rates/new
  def new
    @premium_rate = PremiumRate.new
  end

  # GET /premium_rates/1/edit
  def edit
  end

  # POST /premium_rates or /premium_rates.json
  def create
    @premium_rate = PremiumRate.new(premium_rate_params)

    respond_to do |format|
      if @premium_rate.save
        format.html { redirect_to premium_rate_url(@premium_rate), notice: "Premium rate was successfully created." }
        format.json { render :show, status: :created, location: @premium_rate }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @premium_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /premium_rates/1 or /premium_rates/1.json
  def update
    respond_to do |format|
      if @premium_rate.update(premium_rate_params)
        format.html { redirect_to premium_rate_url(@premium_rate), notice: "Premium rate was successfully updated." }
        format.json { render :show, status: :ok, location: @premium_rate }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @premium_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /premium_rates/1 or /premium_rates/1.json
  def destroy
    @premium_rate.destroy

    respond_to do |format|
      format.html { redirect_to premium_rates_url, notice: "Premium rate was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_premium_rate
      @premium_rate = PremiumRate.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def premium_rate_params
      params.require(:premium_rate).permit(:batch_id, :premium, :min_age, :max_age)
    end
end
