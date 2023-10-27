class BatchImportCoverage
  def initialize(spreadsheet,id)
    @spreadsheet = spreadsheet
    @batch_id = id
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
      mmbr_id = Member.find_by(last_name: principal_lname, first_name: principal_fname, middle_name: principal_mname, birth_date: r_cbdate)&.id
      
      if mmbr_id.nil?
        #CHECK EXISTING MEMBER, SKIP THIS ROW IF TRUE
        next
      else
        coverage_id = Coverage.find_by(batch_id: @batch_id, member_id: mmbr_id)&.id
        if coverage_id.nil?
          #CHECK for EXISTING coverage, ADD NEW IF NIL
          coverage = Coverage.find_or_initialize_by(
            batch_id: @batch_id,
            member_id: mmbr_id,
            loan_certificate: coverage_hash[:loan_certificate],
            loan_coverage: coverage_hash[:loan_coverage],
            age: coverage_hash[:age],
            effectivity: coverage_hash[:effectivity],
            expiry: coverage_hash[:expiry],
            term: coverage_hash[:term],
            status: coverage_hash[:status]
          )
          #raise "errors"
          coverage.assign_attributes(coverage_hash)
          coverage.save!
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
end