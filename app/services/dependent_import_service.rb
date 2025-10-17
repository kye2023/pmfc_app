class DependentImportService
  def initialize(spreadsheet,bid)
    @spreadsheet = spreadsheet
    @branch_id = bid
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
      
      # member_id = Member.find_by(last_name: principal_lname, first_name: principal_fname, middle_name: principal_mname[0])&.id
      # "SELECT id FROM members WHERE last_name="Dela cruz" AND first_name="Juan" AND middle_name="P" "
      member_id = Member.where(last_name: principal_lname, first_name: principal_fname).where("middle_name LIKE ?", "#{principal_mname[0]}%").first
     
      # raise "errors"
      if member_id.blank? == false
        
        dependent = Dependent.where(member_id: member_id,last_name: dependent_hash[:last_name],first_name: dependent_hash[:first_name]).where("middle_name LIKE ?", "#{dependent_hash[:middle_name][0]}%").where(birth_date: dependent_hash[:birth_date])
        
        # raise "errors"

        if dependent.blank? == false
          row["STATUS"] = "Existing"
          row["Remarks"] = "O"
          row["Current Age"] = "X"
          next
        else
          new_dep = ageValidity(dependent_hash[:birth_date], dependent_hash[:relationship])
          if new_dep == true
            dependent_hash[:member_id] = member_id.id
            new_dependent = Dependent.create(dependent_hash)
            new_dependent.assign_attributes(dependent_hash)
            new_dependent.save!
            row["STATUS"] = "New"
            row["Remarks"] = "O"
            row["Current Age"] = "X"
            next
          else
            row["STATUS"] = "Invalid"
            row["Remarks"] = "Sibling & Child must be 3-21 y/o, Spouse & Parent must be 18-65 y/o"
            row["Current Age"] = "#{getCurrentAge(dependent_hash[:birth_date])} y/o"
            next
          end
        end

      else
        row["STATUS"] = "Unlisted"
        row["Remarks"] = "X"
        row["Current Age"] = "X"
        next
      end
      
    end

    # "Success"
    
  end

  def ageValidity(bday, rel)
    age = ((Date.today - bday.to_date) / 365).round
    rel = rel.downcase
    
    if ["spouse", "parent"].include?(rel.downcase) && (18..65).include?(age)
      return true
    elsif ["child", "sibling"].include?(rel.downcase) && (3..21).include?(age)
      return true
    else
      return false
    end

  end

  def getCurrentAge(bday)
    age = ((Date.today - bday.to_date) / 365).round
    return age
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