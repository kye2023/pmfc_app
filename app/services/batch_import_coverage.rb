class BatchImportCoverage
  def initialize(spreadsheet,bid)
    @spreadsheet = spreadsheet
    @batch_id = bid
  end

  def import
    headers = extract_headers(@spreadsheet, "LPPI")
    if headers.nil?
      return "Incorrect/Missing Sheet"
    end

    dependents_spreadsheet = parse_file('LPPI')
    
    require 'date'

    #drop 1 - header excluded
    dependents_spreadsheet.drop(1).each do |row|

      certificate_num = row["CERTNO"]
      principal_lname = row["LASTNAME"].strip.upcase
      principal_fname = row["FIRSTNAME"].strip.upcase
      principal_mname = row["MI"].strip.upcase

      cvg_resdncy = row["RESIDENCY"]
      cvg_cname = row["CENTER_NAME"]
      r_cbdate = row["BIRTHDATE"]
      r_cef_date = row["EFFECTIVITYDATE"]

      #effectivity format method
      formatted_efdate = get_dformatted(nil, r_cef_date, "effectivity") 
      formatted_cbdate = get_dformatted(r_cbdate, nil, "birth_date") 
      
      # CHECK EXISTING MEMBER, RETURN id IF EXIST
      mmbr_data = Member.where(last_name: principal_lname, first_name: principal_fname, birth_date: formatted_cbdate).where(Member.arel_table[:middle_name].matches("#{principal_mname[0]}%")).first
      
      if mmbr_data.present? == true && mmbr_data.id.nil? == false
        #CHECK if DB member meet the params from excel row
        check_coverage = Coverage.where("effectivity  LIKE ?", "#{Date.today.year}%").where(member_id: mmbr_data.id)
        
        if check_coverage.present? == true
          # CHECK for latest coverage
          # raise "errors"
          retrieve_coverage = check_coverage.order(:effectivity,:expiry).last
          cov_aging = retrieve_coverage.coverage_aging

          center_id = verify_center(cvg_cname)
          gresidency = verify_residency(mmbr_data, cvg_resdncy)

          coverage_hash = 
          {
            batch_id: @batch_id,member_id: mmbr_data.id,loan_certificate: row["CERTNO"] == nil ? nil : row["CERTNO"],age: row["AGE"] == nil ? nil : row["AGE"],
            loan_coverage: row["AMOUNTOFLOAN"] == nil ? nil : row["AMOUNTOFLOAN"],effectivity: formatted_efdate,grace_period: row["GRACEPERIOD"] == nil ? nil : row["GRACEPERIOD"],term: row["TERM"] == nil ? nil : row["TERM"],residency: gresidency,status: row["STATUS"] == nil ? nil : row["STATUS"],center_name_id: center_id
          }

          if cov_aging <= 0
            
            chk_fr_cvg = check_coverage.where(loan_coverage: coverage_hash[:loan_coverage], effectivity: coverage_hash[:effectivity], term: coverage_hash[:term] )
            if chk_fr_cvg.present? == true
              
              row["up_STATUS"] = "Existing"
              row["cvgID"] = retrieve_coverage.id
              next
            else
              # CHECK for VALIDITY (for renewal or existing)
              icoverage = Coverage.new(coverage_hash)
              # Calls method from coverage model
              icoverage.compute_age
              icoverage.save!
              scoverage = Coverage.find_by(batch_id: @batch_id, member_id: mmbr_data.id)
              cdpndnt = dependent_coverage_save(scoverage.id, mmbr_data.id, scoverage.residency, scoverage.term)  
              row["up_STATUS"] = "Renewed"
              row["cvgID"] = retrieve_coverage.id
              next
            end

          else
            
            row["up_STATUS"] = "Active"
            row["cvgID"] = retrieve_coverage.id
            next

          end

        else
          # CHECK for OLD coverage (effectivity, expiry, loan_coverage)
          center_id = verify_center(cvg_cname)
          coverage_new_hash = 
          {
            batch_id: @batch_id,member_id: mmbr_data.id,loan_certificate: row["CERTNO"] == nil ? nil : row["CERTNO"],age: row["AGE"] == nil ? nil : row["AGE"],
            loan_coverage: row["AMOUNTOFLOAN"] == nil ? nil : row["AMOUNTOFLOAN"],effectivity: formatted_efdate,grace_period: row["GRACEPERIOD"] == nil ? nil : row["GRACEPERIOD"],term: row["TERM"] == nil ? nil : row["TERM"],residency: row["RESIDENCY"],status: row["STATUS"] == nil ? nil : row["STATUS"],
            center_name_id: center_id
          }
          iicoverage = Coverage.new(coverage_new_hash)
          # Calls method from coverage model
          iicoverage.compute_age
          iicoverage.save!
          scoverage = Coverage.find_by(batch_id: @batch_id, member_id: mmbr_data.id)
          cdpndnt = dependent_coverage_save(scoverage.id, mmbr_data.id, scoverage.residency, scoverage.term)
          row["up_STATUS"] = "New"
          row["cvgID"] = "-"
          next
        end

      else

        #SKIP THIS ROW IF TRUE/no record(s) found, count as non-enrolled
        row["up_STATUS"] = "Unlisted"
        row["cvgID"] = "-"
        next
        
      end
      
    end
   
    # "Success\n#{up_loaded}\n#{e_xisting}\n#{new_member_counter}"
    
  end

#----------------------------------------COVERAGE-method--------------------------------------------------------

def get_dformatted(cbdate, efdate, type)

  if cbdate.nil? == false && efdate.nil? == true && type == "birth_date"
    if cbdate.class == String    
      parse_date = Date.strptime(cbdate, "%m/%d/%Y")
      fcbdate = parse_date.strftime("%Y-%m-%d")
    else
      fcbdate = cbdate   
    end
  else
    if efdate.class == String 
      parse_efdate = Date.strptime(efdate, "%m/%d/%Y")
      fefdate = parse_efdate.strftime("%Y-%m-%d")
    else
      fefdate = efdate
    end
  end

end

def verify_center(excl_center)
  excl_center = CenterName.find_by(description: excl_center)&.id
end

def verify_residency(arr, excl_residency)
  if excl_residency.nil? == false && excl_residency.to_s.match?(/\A-?\d+\Z/) == true
    excl_residency
  else
    excl_residency = arr.coverages.sum(:term)
  end
end

#------------------------------------DEPENDENT-method--------------------------------------

def dependent_coverage_save(cvrgid, mmbrid, residency, term)
  #Add record to DependentCoverage
  
  dependent = Dependent.where(member_id: mmbrid)
    dependent.each do |dpndnt|
      
      mmbr_type = dpndnt.relationship
      msc = mmbr_type.strip.capitalize
      dgpremium = get_dependent_gpremium_gbenefits(residency,term,msc,"gp")
      dgbenefits = get_dependent_gpremium_gbenefits(residency,term,msc,"gb")

      dep_coverage = DependentCoverage.find_or_initialize_by(
        coverage_id: cvrgid,dependent_id: dpndnt.id,
        member_id: dpndnt.member_id,group_benefit_id: dgbenefits,premium: dgpremium
      )
      #raise "errors"
      dep_coverage.save!
    end
    
end  

def get_dependent_gpremium_gbenefits(residency,term,membertype,type)
  group_premium = 0
  group_benefit_id = 0
  membertype

  case membertype
  when "Spouse"
    membertype = 'spouse'
  when "Child"
    membertype = 'child'
  when "Parent"
    membertype = 'parent'
  end

  if type == "gp"
    gp = GroupPremium.where('? between residency_floor and residency_ceiling', residency)
    group_premium = gp.find_by(member_type: "#{membertype}", term: term).premium unless gp.nil?
      
    return group_premium
  else
    gb = GroupBenefit.where('? between residency_floor and residency_ceiling', residency)
    group_benefit_id = gb.find_by(member_type: "#{membertype}").id
      
    return group_benefit_id
  end 
end

private
  def extract_headers(spreadsheet, sheet_name)
    begin
      spreadsheet.sheet(sheet_name).row(1).map(&:strip)
    rescue RangeError
      return nil
    end
  end

  def parse_file(sheet_name)
    @spreadsheet.sheet(sheet_name).parse(headers: true).delete_if { |row| row.all?(&:blank?) }
  end

  def find_missing_headers(required_headers, headers)
    required_headers - headers
  end

end