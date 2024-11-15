class BatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_batch, only: %i[ show edit update destroy import_cov batch_submit batch_preview]
  
  require 'csv'

  def batch_submit 
    @check_loans = Coverage.where(batch_id: @batch.id)
    if @check_loans.size > 0
      @batch.update(submit: 1)
      respond_to do |format| 
        format.html { redirect_to batch_url(@batch, qry: 0, pln: 0, pth: "b1"), notice: "Batch was successfully submitted." }
      end
    else
      respond_to do |format| 
        format.html { redirect_to batch_url(@batch, qry: 0, pln: 0, pth: "b1"), alert: "Unable to save, No loan(s) recorded." }
      end
    end
   
  end
  
  # GET /batches or /batches.json
  def index
    require 'pagy/extras/bootstrap'
    
    @batches = Batch.get_batches_index(current_user.admin, params[:query], current_user)

    @pagy, @batches = pagy(@batches, items: 10)

    # if current_user.admin == true
    #   @batches = Batch.all
    # else
    #   @batches = Batch.where(branch_id: current_user.user_detail.branch_id)
    # end
   
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
    path = params[:pth]
    params[:query]

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
    when "0119"
      @show_coverage = @batch.coverages.where("residency BETWEEN 0 AND 119")
    when "120a"
      @show_coverage = @batch.coverages.where("residency > 120")
    else
      @show_coverage = @batch.coverages.limit(100) #SELECT `coverages`.* FROM `coverages` WHERE `coverages`.`batch_id` = '28' LIMIT 100
    end

    #search bar
    if params[:query].present?
      @show_coverage = @batch.coverages.joins(:member).where("members.last_name LIKE ? OR members.first_name LIKE ?", "#{params[:query]}", "#{params[:query]}")
      # SELECT `coverages`.* FROM `coverages` INNER JOIN `members` ON `members`.`id` = `coverages`.`member_id` WHERE `coverages`.`batch_id` = '28' AND (members.last_name LIKE 'gaspar' OR members.first_name LIKE 'gaspar')

      # @show_coverage = @show_coverage.joins(:member).where("members.last_name LIKE ? OR members.first_name LIKE ?", "#{params[:query]}", "#{params[:query]}")
      # SELECT `coverages`.* FROM `coverages` INNER JOIN `members` ON `members`.`id` = `coverages`.`member_id` WHERE `coverages`.`batch_id` = '28' AND (members.last_name LIKE 'gaspar' OR members.first_name LIKE 'gaspar') LIMIT 100
    end
    
    @pagy, @show_coverage = pagy(@show_coverage, items: 25)

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

  def load_batch
    @batch_title = Batch.where(submit: 0)
    render json: @batch_title
  end

  def find_batch
    @btitle = params[:btitle]
    @btdescription = params[:bdesc]
    @bbatches = Batch.where(title: @btitle, description: @btdescription)
    # raise "errors"
    render json: @bbatches
  end

  def add_new_batch
    @bId = params[:Id]
    @btitle = params[:title]
    @bdesc = params[:desc]
    @btarget = params[:target]
      
    @find_batch = Batch.find_or_initialize_by(branch_id: @bId,title: @btitle,description: @bdesc)
    # raise "errors"
    if @find_batch.persisted? == false
      @find_batch.save
      @batch_title = Batch.where(submit: 0)
      render turbo_stream: [ turbo_stream.update(@btarget, partial: "batches/load_bselect", locals: { lBname: @batch_title }) ]
    end
  end

  def import
    batch_id = params[:p]
    import_service = ImportService.new(:batch, params[:file], batch_id)
    import_message = import_service.import
    # redirect_to batches_path, notice: import_message
    if import_message.present? && import_message == "No file uploaded"
      flash[:notice] = "No file uploaded"
      redirect_to batches_path
    else
      mcount = 0
      ucount = 0
      # ul_arname = []
      status_names = import_message.map do |r|
        lname = r["LASTNAME"].upcase
        fname = r["FIRSTNAME"].upcase
        mname = r["MI"].upcase
        bdate = r["BIRTHDATE"]
        arr_sts = r["up_STATUS"]
        cId = r["cvgID"]
        ul_name = "#{lname}"+", "+"#{fname}"+", "+"#{mname}"
        mcount+=1

        if arr_sts == "Unlisted"
          # ucount+=1
          "#{mcount}. #{ul_name} - #{arr_sts} (Member enrollment required.)"
          # ul_arname << [lname, fname, mname, bdate]
          # "#{ucount}. #{ul_name} - #{arr_sts} #{view_context.link_to('Enroll', new_member_path(unlisted: ul_arname), target: '_blank')}"
          # ucount.to_s+". "+lname+", "+fname+" "+mname+" - "+r["up_STATUS"]+"#{view_context.link_to('Enroll', new_member_path(unlisted: import_message[mcount-1]), target: '_blank')}"
        elsif arr_sts == "Active"
          "#{mcount}. #{ul_name} - #{view_context.link_to("#{arr_sts}", coverage_path(cId, activeID: cId), target: '_blank')}"
        end

      end.compact 

      status_count = import_message.group_by { |message| message["up_STATUS"] }.map { |status, messages| [status, messages.size] }.to_h
      
      # raise "errors"

      flash_existing = status_count["Existing"]
      flash_renewal = status_count["Renewed"]
      flash_unlisted = status_count["Unlisted"]
      flash_new = status_count["New"]
      flash_active = status_count["Active"]

      flash_names = status_names.map { |status_names| "#{status_names}<br>" }.join
    
      flash[:notice] = "Import successful. <br><br> Active : #{flash_active} <br> Existing : #{flash_existing} <br> Renewed : #{flash_renewal} <br> Unlisted : #{flash_unlisted} <br> New : #{flash_new} <br>"

      if flash_unlisted.present? == true && flash_unlisted > 0 || flash_active.present? == true && flash_active > 0
        # flash[:notice] += flash_names
        flash[:notice] += "<br>#{view_context.link_to('View Remark(s)', unlisted_preview_batch_path(batch_id, unlisted: flash_names), data: {turbo_frame: "remote_modal"})}"
      end

      redirect_to batches_path
    end
    
  end

  def import_coverages
    # batch_id = @batch.id
    # import_service = ImportService.new(:coverage, params[:file], batch_id)
    # import_message = import_service.import
    # redirect_to batches_path, notice: import_message
  end

  def batch_download
   # require 'prawn/manual_builder'

    # Prawn::ManualBuilder::Chapter.new do
    #   title 'Print Scaling'

    #   text do
    #     prose <<~TEXT
    #       (Optional; PDF 1.6) The page scaling option to be selected when a print
    #       dialog is displayed for this document.  Valid values are
    #       <code>None</code>, which indicates that the print dialog should reflect
    #       no page scaling, and <code>AppDefault</code>, which indicates that
    #       applications should use the current print scaling.  If this entry has an
    #       unrecognized value, applications should use the current print scaling.
    #       Default value: <code>AppDefault</code>.

    #       Note: If the print dialog is suppressed and its parameters are provided
    #       directly by the application, the value of this entry should still be
    #       used.
    #     TEXT
    #   end

    #   example eval: false, standalone: true do
    #     Prawn::Document.generate(
    #       'example.pdf',
    #       page_layout: :landscape,
    #       print_scaling: :none
    #     ) do
    #       text 'When you print this document, the scale to fit in print preview '\
    #         'should be disabled by default.'
    #     end
    #   end
    # end

  end

  def batch_preview
    
    #plan parameter
    plan = ""
    ppln = params[:pln]
    if ppln == "0"
      plan = "LPPI"
    else
      plan = "SGYRT"
    end

    if plan == "LPPI"
# for LPPI      
      #Initialize PDF
      #pdf = Prawn::Document.new(page_layout: :landscape)
      pdf = Prawn::Document.new
      pdf.image "#{Prawn::DATADIR}/pmfc.png", scale: 0.15
      pdf.move_down 5
      pdf.text "PEOPLE'S MICRO FINANCE COOPERATIVE"
      pdf.move_down 5

      #Block/Border Title
      data_zero = [ ["#{"Title :"+@batch.title+"\n Branch :"+@batch.branch.name+"\n Description :"+@batch.description+"\n Plan :"+plan}"] ]
      pdf.table(data_zero, :cell_style => { :font => "Times-Roman", :size => 12}, :width => 540 )
      pdf.move_down 20

      #Table Header
      datazero = [["#","Certificate", "Name", "Sum Insured", "Effectivity", "Expiry", "Term","Status","Premium"]]
      
      #Table Body (Active Record)
      total_sumi = 0
      total_prem = 0

      @batch.coverages.each do |c|
        count_dpnt = c.dependent_coverages.count(:id).to_s
        s_age = c.age.to_s
        s_rcdncy=c.residency.to_s
       
        loan_prem = c.loan_premium
        total_prem += loan_prem

        dependent_prem = c.dependent_coverages.sum(:premium)
        group_prem = c.group_premium
  
        datazero +=
        [[
          "#{c.id}",
          "#{c.group_certificate}",
          "#{c.member.get_cmember}",
          "#{helpers.to_curr(c.loan_coverage)}",
          "#{(c.effectivity).strftime("%m/%d/%Y")}",
          "#{(c.expiry).strftime("%m/%d/%Y")}",
          "#{c.term}",
          "#{c.status[0,1]}",
          "#{helpers.to_curr(loan_prem)}"
        ]]
        total_sumi += c.loan_coverage
        
      end  
      
      #Table Footer
      datazero +=[[
        {:content => "Grand Total :", :colspan => 3, align: :right },"#{helpers.to_curr(total_sumi)}",
        {:content => "Total Gross Premium Due :", :colspan => 4, align: :right },"#{helpers.to_curr(total_prem)}"
      ]]
      datazero += [[{:content => "Less Service Fee :", :colspan => 8, align: :right },"-"]]
      datazero += [[{:content => "Total Net Premium Due :", :colspan => 8, align: :right },"#{helpers.to_curr(total_prem)}"]]
  
      #Table Format
      pdf.table(datazero, :cell_style => { :font => "Times-Roman", :size => 10 } ) do
        columns(2).width = 130
        columns(3).width = 80
      end  
      pdf.move_down 20
  
      #Certification
      data_subzero = [[
        "I/We hereby certify that the above listed members who do not have any health problem/declaration are not bedridden, and are able to perform the 5 activities of daily living (eating/feeding, toileting, mobility/ transferring, bathing, dressing) and not hospitalized within six (6) months prior to the application for insurance and therefore are eligible for insurance coverage."
      ]]
      pdf.table(data_subzero, :cell_style => { :font => "Times-Roman", :size => 10}, :width => 540 )
      pdf.move_down 5
      pdf.text "Certified by:"
      pdf.move_down 20   
  
      data_botone = [["Full Name, Date & Signature","Full Name, Date & Signature"]]    
      data_bottwo = [["Title/Position","Title/Position"]]    
      pdf.table(data_botone, :cell_style => { :font => "Times-Roman", :size => 10, align: :center, :borders => [] }, :width => 540 )
      pdf.move_down 20 
      pdf.table(data_bottwo, :cell_style => { :font => "Times-Roman", :size => 10, align: :center, :borders => [] }, :width => 540 )
    else
# for SGYRT
      #Initialize PDF
      pdf = Prawn::Document.new(page_layout: :landscape)
      pdf.image "#{Prawn::DATADIR}/pmfc.png", scale: 0.15
      pdf.move_down 5
      pdf.text "PEOPLE'S MICRO FINANCE COOPERATIVE"
      pdf.move_down 5

      #Block/Border Title
      data_zero = [ ["#{"Title :"+@batch.title+"\n Branch :"+@batch.branch.name+"\n Description :"+@batch.description+"\n Plan :"+plan}"] ]
      pdf.table(data_zero, :cell_style => { :font => "Times-Roman", :size => 12}, :width => 720 )
      pdf.move_down 20

      #Table Header
      datazero = [[
        "Certificate",
        "#",
        "",
        "Name", 
        "Age",
        {:content => "Relationship", :rotate => -30},
        {:content => "Residency", :rotate => -30}, 
        {:content => "Sum Insured", :rotate => -30}, 
        "Effectivity", 
        "Expiry", 
        "Term",
        "Coverage\nstatus\n(New/\nRenewal)",
        "Premium"
      ]]
      
      #Table Body (Active Record)
      
      msum_life = 0
      dsum_life = 0

      msum_prem = 0
      dsum_prem = 0

      total_sumi = 0
      total_prem = 0
      mcount = 0

      @batch.coverages.each do |c|
        
        count_dpnt = c.dependent_coverages.count(:id).to_s
        s_age = c.age.to_s
        s_rcdncy=c.residency.to_s
       
        mbr_gprem = c.group_premium
        msum_prem += mbr_gprem
        #dsum_prem = c.dependent_coverages.sum(:premium)
        
        mgb_life = c.group_benefit.life
        msum_life += mgb_life

        effdate = helpers.to_shortdate(c.effectivity)
        expdate = helpers.to_shortdate(c.expiry)
        mterm = c.term
        mstatus = c.status

        mcount += 1

        datazero +=
        [[
          "#{c.group_certificate}",
          "#{mcount}",
          "",
          "#{c.member.get_cmember}",
          "#{s_age+" y/o"}",
          "Principal",
          "#{c.residency}",
          "#{helpers.to_curr(mgb_life)}",
          "#{effdate}",
          "#{expdate}",
          "#{mterm}",
          "#{mstatus}",
          "#{helpers.to_curr(mbr_gprem)}"
        ]]

        dcount = 0
        mresidency = c.residency

        c.dependent_coverages.each do |d|

          dname = d.dependent.full_name
          dage = c.member.compute_cmmbrage(c.effectivity,d.dependent.birth_date)
          drelation = d.dependent.relationship.capitalize()
          
          dpremium = d.premium
          dsum_prem += dpremium
          dgb_life = d.group_benefit.life
          dsum_life += dgb_life

          dcount += 1

          datazero +=
          [[
            "",
            "",
            "#{c.member.alpharray(dcount)}",
            "#{dname}",
            "#{dage}",
            "#{drelation}",
            "#{mresidency}",
            "#{helpers.to_curr(dgb_life)}",
            "#{effdate}",
            "#{expdate}",
            "#{mterm}",
            "#{mstatus}",
            "#{dpremium}"
            ]]
        end  

        total_sumi = ((msum_life)+(dsum_life))
        total_prem = ((msum_prem)+(dsum_prem))
        
      end  

       #Table Footer
       datazero +=[[
        {:content => "Grand Total :", :colspan => 7, align: :right },"#{helpers.to_curr(total_sumi)}",
        {:content => "Total Gross Premium Due :", :colspan => 4, align: :right },"#{helpers.to_curr(total_prem)}"
      ]]
      datazero += [[{:content => "Less Service Fee :", :colspan => 12, align: :right },"..."]]
      datazero += [[{:content => "Total Net Premium Due :", :colspan => 12, align: :right },"#{helpers.to_curr(total_prem)}"]]

      #Table Format
      pdf.table(datazero, :cell_style => { :font => "Times-Roman", :size => 10 } ) do
        columns(3).width = 130
        columns(4).width = 35
        columns(5).width = 60
        columns(11).width = 50
      end   
      pdf.move_down 20
      
       #Certification
      data_subzero = [[
        "I/We hereby certify that the listed members in this Summary Report/List of Persons to be Insured do not have any health problems, not bedridden, and are able to perform the five (5) activities of daily living (eating/feeding, toileting, mobility/ transferring, bathing, dressing) and not hospitalized within six (6) months prior to the application for insurance and therefore are eligible for insurance coverage. 

        I/We hereby certify that the statements in this Summary Report/List of Persons to be Insured are "'true and correct'" to the best of my/our knowledge. I/We understand and agree that any "'false statement'", "'misrepresentation'", or "'omission of facts'" in this report shall render the insurance “contestable” or "'voidable'" at the instance of 1CISP."
      ]]
      pdf.table(data_subzero, :cell_style => { :font => "Times-Roman", :size => 10}, :width => 720 )
      pdf.move_down 10
      pdf.text "Certified by:"
      pdf.move_down 20

      data_botone = [
        [{:content => "Full Name, Date & Signature", align: :center},{:content => "Noted by:", align: :left}],
        [{:content => "", :rowspan => 3},""],
        [""],
        [""],
        [{:content =>"Title/Position", align: :center},""]
      ]
      
      # pdf.table(data_botone, :cell_style => { :font => "Times-Roman", :size => 10, align: :center, :borders => [:bottom] }, :width => 720 )
      pdf.table(data_botone, :cell_style => { :font => "Times-Roman", :size => 10, :borders => [] }, :width => 720 ) do
        row(2).borders = [:bottom]
        row(3).borders = [:bottom]
        row(3).padding = 10
      end
    
    end
    
    #Render PDF
    send_data(pdf.render, filename: 'hello.pdf', type: 'application/pdf', disposition: 'inline')

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_batch
      @batch = Batch.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def batch_params
      params.require(:batch).permit(:title, :description, :branch_id, :submit)
    end
end
