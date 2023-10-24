class MemberImportService
  def initialize(spreadsheet)
    @spreadsheet = spreadsheet
  end
  
  def import
    headers = extract_headers(@spreadsheet, "MemberMasterlist")
    if headers.nil?
      return "Incorrect/Missing Sheet"
    end

    members_spreadsheet = parse_file('MemberMasterlist')
  
    #drop 1 - header excluded
    members_spreadsheet.drop(1).each do |row|
      member_hash = {
        last_name: row["LASTNAME"] == nil ? nil : row["LASTNAME"].strip,
        first_name: row["FIRSTNAME"] == nil ? nil : row["FIRSTNAME"].strip,
        middle_name: row["MI"] == nil ? nil : row["MI"].strip,
        birth_date: row["BIRTHDATE"] == nil ? nil : row["BIRTHDATE"],
        date_membership: row["DATEOFMEMBERSHIP"] == nil ? nil : row["DATEOFMEMBERSHIP"],
        civil_status: row["CIVILSTATUS"] == nil ? nil : row["CIVILSTATUS"].strip,
        gender: row["GENDER"] == nil ? nil : row["GENDER"].strip,
        mobile_no: row["MOBILENO"] == nil ? nil : row["MOBILENO"],
        email: row["EMAIL"] == nil ? nil : row["EMAIL"].strip
      }
    

      member = Member.find_or_initialize_by(
        last_name: member_hash[:last_name],
        first_name: member_hash[:first_name],
        middle_name: member_hash[:middle_name],
        birth_date: member_hash[:birth_date]
      )

      member.assign_attributes(member_hash)
      member.save!
      
      # if member.persisted?
      #  member.update(member_hash)
      #  next
      # else
      #   new_member = Member.create(member_hash)
      # end
    
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
