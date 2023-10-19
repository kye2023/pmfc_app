class Dependent < ApplicationRecord
  validates_presence_of :last_name, :first_name, :middle_name, :birth_date
  belongs_to :member

  def to_s
    "#{last_name}" + ", " + "#{first_name}" + " " + "#{middle_name[0.1]}" + ". "
  end

  def get_formatted_dbday
    bday = birth_date.strftime("%m/%d/%Y")
  end


end
