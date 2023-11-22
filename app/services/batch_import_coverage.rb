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
    
    
    #drop 1 - header excluded
    dependents_spreadsheet.drop(1).each do |row|
      

      principal_lname = row["LASTNAME"].strip.upcase
      principal_fname = row["FIRSTNAME"].strip.upcase
      principal_mname = row["MI"].strip.upcase
      
      r_cbdate = row["BIRTHDATE"]
      r_cef_date = row["EFFECTIVITYDATE"]
      r_cex_date = row["EXPIRYDATE"]


      if r_cbdate.class == String && r_cef_date.class == String && r_cex_date.class == String
        parse_date = Date.strptime(r_cbdate,"%m/%d/%Y")
          formatted_cbdate = parse_date.strftime("%Y-%m-%d")
        parse_efdate = Date.strptime(r_cef_date,"%m/%d/%Y")
          formatted_efdate = parse_efdate.strftime("%Y-%m-%d")
        parse_exdate = Date.strptime(r_cex_date,"%m/%d/%Y")
          formatted_exdate = parse_exdate.strftime("%Y-%m-%d")
      else
        formatted_cbdate = r_cbdate
        formatted_efdate = r_cef_date
        formatted_exdate = r_cex_date
      end
      
      coverage_hash = {
        loan_certificate: row["CERTNO"] == nil ? nil : row["CERTNO"],
        age: row["AGE"] == nil ? nil : row["AGE"],
        loan_coverage: row["AMOUNTOFLOAN"] == nil ? nil : row["AMOUNTOFLOAN"],
        effectivity: formatted_efdate,
        expiry: formatted_exdate,
        term: row["TERM"] == nil ? nil : row["TERM"],
        status: row["STATUS"] == nil ? nil : row["STATUS"]
      }
      
      #CHECK EXISTING MEMBER, RETURN id IF EXIST
      mmbr_data = Member.find_by(last_name: principal_lname, first_name: principal_fname, middle_name: principal_mname, birth_date: r_cbdate)
     
      if mmbr_data.id.nil?
        #CHECK EXISTING MEMBER, SKIP THIS ROW IF TRUE
        next
      else
        coverage_id = Coverage.find_by(batch_id: @batch_id, member_id: mmbr_data.id)&.id
        mmbr_dom = mmbr_data.date_membership
        if coverage_id.nil?
          #CHECK for EXISTING coverage, ADD NEW IF NIL
            #METHOD calling for (loan premium, rate, residency, group benefits)
          gloanpremium = get_loan_premium(coverage_hash[:age],coverage_hash[:loan_coverage],coverage_hash[:term])
          gprate = get_premium_rate(coverage_hash[:age])  

          gresidency = get_cresidency(formatted_efdate,formatted_exdate,mmbr_dom)
          g_gpremium = get_gpremium_gbenefits(gresidency,coverage_hash[:term],"gp")
          g_gbenefits = get_gpremium_gbenefits(gresidency,coverage_hash[:term],"gb") 

          coverage = Coverage.find_or_initialize_by(
            batch_id: @batch_id,member_id: mmbr_data.id,loan_certificate: coverage_hash[:loan_certificate],
            loan_coverage: coverage_hash[:loan_coverage],age: coverage_hash[:age],effectivity: formatted_efdate,expiry: formatted_exdate,
            term: coverage_hash[:term],status: coverage_hash[:status],residency: gresidency,loan_premium: gloanpremium,group_premium: g_gpremium,
            group_certificate: coverage_hash[:loan_certificate],group_benefit_id: g_gbenefits,rate: gprate
          )
          coverage.assign_attributes(coverage_hash)
          coverage.compute_age
          coverage.save!
          scoverage = Coverage.find_by(batch_id: @batch_id, member_id: mmbr_data.id)
          cdpndnt = dependent_coverage_save(scoverage.id, mmbr_data.id, scoverage.residency, scoverage.term)
          

        end
      end

    end

    "Success"

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

  #Coverage method
  def get_cresidency(efdate,exdate,mmbrdom)
    residency = (efdate.year * 12 + efdate.month) - (mmbrdom.year * 12 + mmbrdom.month)
    return residency
  end

  def get_premium_rate(age)

    # SET PREMIUM RATE ACCORDING TO AGE group/range
    rate = 0
    loan_premium = 0
    case age 
    when 18..65 
      rate = 0.83
    when 66..70
      rate = 3
      rate = 4 if loancoverage > 350000
    when 71..75 
      rate = 4
      rate = 5 if loancoverage > 350000
    when 76..80
      rate = 5
      rate = 8.75 if loancoverage > 350000
    end

    return rate
  end

  def get_loan_premium(age,loancoverage,term)

    # SET PREMIUM RATE ACCORDING TO AGE group/range
    rate = 0
    loan_premium = 0
    case age 
    when 18..65 
      rate = 0.83
    when 66..70
      rate = 3
      rate = 4 if loancoverage > 350000
    when 71..75 
      rate = 4
      rate = 5 if loancoverage > 350000
    when 76..80
      rate = 5
      rate = 8.75 if loancoverage > 350000
    end

    loan_premium = ((loancoverage/1000) * (rate * term))
    return loan_premium
  end

  def get_gpremium_gbenefits(residency,term,type)
    group_premium = 0
    group_benefit_id = 0

    if type == "gp"
      gp = GroupPremium.where('? between residency_floor and residency_ceiling', residency)
      group_premium = gp.find_by(member_type: 'principal', term: term).premium unless gp.nil?
      
      return group_premium
    else
      gb = GroupBenefit.where('? between residency_floor and residency_ceiling', residency)
      group_benefit_id = gb.find_by(member_type: 'principal').id
      
      return group_benefit_id
    end 
  end
  
  #DEPENDENT method
  def dependent_coverage_save(cvrgid, mmbrid, residency, term)
    #Add record to DependentCoverage
    
    dependent = Dependent.where(member_id: mmbrid)
      dependent.each do |dpndnt|
        
        mmbr_type = dpndnt.relationship
        dgpremium = get_dependent_gpremium_gbenefits(residency,term,mmbr_type,"gp")
        dgbenefits = get_dependent_gpremium_gbenefits(residency,term,mmbr_type,"gb")
  
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


end