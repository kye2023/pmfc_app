class Member < ApplicationRecord
  validates_presence_of :last_name, :first_name, :middle_name, :birth_date, :civil_status, :gender
  has_many :dependents, dependent: :destroy
  accepts_nested_attributes_for :dependents, reject_if: :all_blank, allow_destroy: true

  has_many :coverages, dependent: :destroy
  has_many :batches, through: :coverages
  belongs_to :branch

  def get_cmember
    "#{last_name.capitalize}" + ", " + "#{first_name.capitalize}" + " " + "#{middle_name[0.1]}" + ". " + "#{suffix}"
  end

  def to_s 
     "#{first_name}" + " " + "#{middle_name[0.1]}." + " " + "#{last_name}" + "#{suffix}"
  end
  
  def get_formatted_bday
    bday = birth_date.strftime("%m/%d/%Y")
  end

  def get_formatted_membership
    bday = date_membership.strftime("%m/%d/%Y")
  end

  def format_bday(bday)
    bday.strftime("%m/%d/%Y")
  end

  def compute_member_age(bday)
    today = Date.today
    cm_age = ((today - bday.to_date) / 365).round
    "#{cm_age}" + " y/o"
  end

  def compute_cmmbrage(efdate,bday)
    cc_mage = ((efdate.year - bday.year)).round
    "#{cc_mage}" + " y/o"
  end

  def count_dependent
    mmbr_id = id
    cdpndnt = Dependent.where(member_id: mmbr_id).count
  end

  def alpharray(val)
    numalpha = Array["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    return numalpha[val-1]
  end
  
  def self.get_members_index(admin, query, current_user)
    if query.present? == true
      if admin == true
        where("last_name LIKE ?", "%#{query}%").limit(25)
      else
        where(branch_id: current_user.user_detail.branch_id).where("last_name LIKE ? OR first_name LIKE ?", "%#{query}%", "%#{query}%").limit(25)
      end
    else
      if admin == true
        all
      else
        where(branch_id: current_user.user_detail.branch_id).limit(100)
      end
    end
  end

  def self.load_members(current_user)
    where(branch_id: current_user.user_detail.branch_id)
  end


end



