class DependentsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_dependent, only: %i[ show edit update destroy ]

  # GET /dependents or /dependents.json
  def index
    # if params[:query].present?
    #   @dependents = Dependent.where("last_name LIKE ?", "%#{params[:query]}%")
    # else
    #   @dependents = Dependent.all
    # end

    @dependents = Dependent.get_dependents_index(current_user.admin, params[:query], current_user)
    
    #set pagination
    @pagy, @dependents = pagy(@dependents, items: 10)

  end

  # GET /dependents/1 or /dependents/1.json
  def show
   
  end

  # GET /dependents/new
  def new
    #@dependent = Dependent.new
    #pass member id parameter @ dependents
    @member = Member.find(params[:m])
    @dependent = @member.dependents.build
    if Rails.env.development?
      dummy_data
    end
  end

  def dummy_data 
    #@dependent.last_name = FFaker::Name.last_name
    @dependent.last_name = @member.last_name
    @dependent.first_name = FFaker::Name.first_name
    @dependent.middle_name = FFaker::Name.first_name[0]
  end
  # GET /dependents/1/edit
  def edit
  end

  # POST /dependents or /dependents.json
  def create
    #@dependent = Dependent.new(dependent_params)
    @member = Member.find(params[:m])
    @dependent = @member.dependents.build(dependent_params)

    if @dependent.valid?
      respond_to do |format|
        if @dependent.save
          format.html { redirect_to @member, notice: "Dependent was successfully created." }
          format.json { render :show, status: :created, location: @dependent }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @dependent.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dependent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dependents/1 or /dependents/1.json
  def update
    respond_to do |format|
      if @dependent.update(dependent_params)
        format.html { redirect_to @member, notice: "Dependent was successfully updated." }
        format.json { render :show, status: :ok, location: @dependent }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dependent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dependents/1 or /dependents/1.json
  def destroy
    @dependent.destroy

    respond_to do |format|
      # format.html { redirect_to dependents_url, notice: "Dependent was successfully destroyed." }
      format.html { redirect_to @member, notice: "Dependent was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def import
    brn_id = current_user.user_detail.branch_id
    import_service = ImportService.new(:dependent,params[:file],brn_id)
    import_message = import_service.import
    # redirect_to dependents_path, notice: import_message
    if import_message.present? && import_message == "No file uploaded"
      flash[:notice] = "No file uploaded"
      redirect_to dependents_path
    else
      mcount = 0
      status_names = import_message.map do |r|
        lname = r["LASTNAME"].capitalize
        fname = r["FIRSTNAME"].capitalize
        mname = r["MI"].upcase
        reln = r["RELATIONSHIP"].capitalize
        rmks = r["Remarks"].capitalize
        c_age = r["Current Age"]
        arr_sts = r["STATUS"]
        ul_name = "#{lname}"+", "+"#{fname}"+", "+"#{mname}"
        mcount+=1

        if arr_sts == "Invalid"
          "#{mcount}. #{ul_name} | #{reln} | - #{arr_sts} age, (#{c_age})"
        end

      end.compact 

      status_count = import_message.group_by { |message| message["STATUS"] }.map { |status, messages| [status, messages.size] }.to_h
      
      # raise "errors"

      flash_existing = status_count["Existing"]
      flash_unlisted = status_count["Unlisted"]
      flash_new = status_count["New"]
      flash_invalid = status_count["Invalid"]

      # flash[:notice] = "Import successful. <br><br> Existing :"+flash_existing.to_s+"<br> Uploaded :"+flash_uploaded.to_s
      flash[:notice] = "Import successful. <br><br> Existing : #{flash_existing} <br> Unlisted : #{flash_unlisted} <br> New : #{flash_new} <br> Invalid : #{flash_invalid}"

      if flash_invalid.present? == true && flash_invalid > 0

        # import_message.select { |hash| hash['STATUS'] == 'Invalid' }
        flash_names = status_names.map { |status_names| "#{status_names}<br>" }.join
        flash[:notice] += "<br>#{view_context.link_to('View Remark(s)', invalid_preview_dependent_path(brn_id, invalid: flash_names), data: {turbo_frame: "remote_modal"})}"
        
      end

      redirect_to dependents_path
    end


  end

  def age_validation

    @bday = params[:dbday]
    @relation = params[:drelation]
    
    @dependent = Dependent.new(birth_date: @bday, relationship: @relation)
    @age_validity = @dependent.is_dep_age_valid
    @dpndt_age = @dependent.current_age

    respond_to do |format|
      format.json { render json: { bday: @bday, age: @dpndt_age, relation: @relation, validity: @age_validity } }
     end
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dependent
      @dependent = Dependent.find(params[:id])
      @member = @dependent.member
    end

    # Only allow a list of trusted parameters through.
    def dependent_params
      params.require(:dependent).permit(:member_id, :last_name, :first_name, :middle_name, :birth_date, :civil_status, :gender, :mobile_no, :email, :relationship, :suffix)
    end
end
