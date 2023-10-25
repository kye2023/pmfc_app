class ImportService
  def initialize (type, file)
    @type = type
    @file = file

  end


  def import
    if file.nil?
      return "No file uploaded"
    elseif !valid_file?
      return "Only csv, xls, and xlsx file format."
    end

    spreadsheet = read_file

    import_service = case @type
                    when :member
                      MemberImportService.new(spreadsheet)
                    end
    import_result = import_service.import                
                    import_result
  end

  private
  attr_reader :file

  def valid_file?
    file.extname(file.path) =~ /csv|xlsx?|xls\z/
  end

  def read_file
    spreadsheet = Roo::Spreadsheet.open(file.path, headers: true)
  end

end