  # This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

spreadsheet = Roo::Spreadsheet.open("./db/uploads/pmfc_premium.xlsx")

(2..spreadsheet.last_row).each do |row|
    gp = GroupPremium.find_or_initialize_by(member_type: spreadsheet.cell(row, 'A'), term: spreadsheet.cell(row, 'B'), residency_floor: spreadsheet.cell(row, 'C'))
    gp.term = spreadsheet.cell(row,'B')
    gp.residency_floor = spreadsheet.cell(row,'C')
    gp.residency_ceiling = spreadsheet.cell(row,'D')
    gp.premium = spreadsheet.cell(row,'E')
    puts "#{gp.member_type}" if gp.save!
end

spreadsheet = Roo::Spreadsheet.open("./db/uploads/pmfc_premium.xlsx")

(2..spreadsheet.last_row).each do |row|
    gp = GroupBenefit.find_or_initialize_by(member_type: spreadsheet.cell(row, 'G'),  residency_floor: spreadsheet.cell(row, 'H'))
    gp.residency_ceiling = spreadsheet.cell(row,'I')
    gp.life = spreadsheet.cell(row,'J')
    gp.add = spreadsheet.cell(row,'K')
    gp.burial = spreadsheet.cell(row,'L')
    puts "#{gp.member_type}" if gp.save!
end

spreadsheet = Roo::Spreadsheet.open("./db/uploads/pmfc_roo.xlsx")

(2..spreadsheet.last_row).each do |row|
    b = Branch.find_or_initialize_by(name: spreadsheet.cell(row, 'A'))
    puts "#{b.name}" if b.save!
end
spreadsheet = Roo::Spreadsheet.open("./db/uploads/pmfc_roo.xlsx")

(2..spreadsheet.last_row).each do |row|
    unless spreadsheet.cell(row, 'C').nil?
      b = Benefit.find_or_initialize_by(name: spreadsheet.cell(row, 'C'))
      puts "#{b.name}" if b.save!
    end
end