class DependentImportService
  def initialize(spreadsheet)
    @spreadsheet = spreadsheet
  end

  def import
    headers = extract_headers(@spreadsheet, "DependentMasterlist")
    if headers.nil?
      return "Incorrect/Missing Sheet"
    end

    dependents_spreadsheet = parse_file('DependentMasterlist')
    
    
    #drop 1 - header excluded
    dependents_spreadsheet.drop(1).each do |row|
      #iteration per row
      #Break string into array - Principal column
      splt_principal = row["PRINCIPAL"].split(",")
      principal_lname = splt_principal[0].strip.upcase
      principal_fname = splt_principal[1].strip.upcase
      principal_mname = splt_principal[2].strip.upcase
      
      rdbdate = row["BIRTHDATE"]

      if rdbdate.class == String
        parse_date = Date.strptime(rdbdate,"%m/%d/%Y")
        formatted_dbirthdate = parse_date.strftime("%Y-%m-%d")
      else
        formatted_dbirthdate = rdbdate
      end
      
      dependent_hash = {
        last_name: row["LASTNAME"] == nil ? nil : row["LASTNAME"].strip,
        first_name: row["FIRSTNAME"] == nil ? nil : row["FIRSTNAME"].strip,
        middle_name: row["MI"] == nil ? nil : row["MI"].strip,
        birth_date: formatted_dbirthdate,
        civil_status: row["CIVILSTATUS"] == nil ? nil : row["CIVILSTATUS"].strip,
        gender: row["GENDER"] == nil ? nil : row["GENDER"],
        mobile_no: row["MOBILENO"] == nil ? nil : row["MOBILENO"],
        email: row["EMAIL"] == nil ? nil : row["EMAIL"],
        relationship: row["RELATIONSHIP"] == nil ? nil : row["RELATIONSHIP"]
      }
      
      member_id = Member.find_by(last_name: principal_lname, first_name: principal_fname, middle_name: principal_mname)&.id
      # "SELECT id FROM members WHERE last_name="Dela cruz" AND first_name="Juan" AND middle_name="P" "
      
      if member_id.nil?
        next
      else
        dependent = Dependent.find_or_initialize_by(
          member_id: member_id,
          last_name: dependent_hash[:last_name],
          first_name: dependent_hash[:first_name],
          middle_name: dependent_hash[:middle_name],
          birth_date: dependent_hash[:birth_date]
        )

        #new_dependent = Dependent.create(dependent_hash)
        dependent.assign_attributes(dependent_hash)
        dependent.save!
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