class Member < ApplicationRecord
  validates_presence_of :last_name, :first_name, :middle_name, :birth_date, :date_membership
  has_many :coverages
  has_many :batches, through: :coverages
  #has_many :dependent, inverse_of: :member
  #accepts_nested_attributes_for :dependent, reject_if: :all_blank, allow_destroy: true

  def get_cmember
    "#{last_name}" + ", " + "#{first_name}" + " " + "#{middle_name[0.1]}" + ". "
  end
  
  def get_formatted_bday
    bday = birth_date.strftime("%m/%d/%Y")
  end

  def format_bday(bday)
    bday.strftime("%m/%d/%Y")
  end

  def compute_member_age(bday)
    today = Date.today
    cm_age = ((today - bday.to_date) / 365).round
    "#{cm_age}" + " y/o"
  end


end



