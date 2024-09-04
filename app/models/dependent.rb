class Dependent < ApplicationRecord
  validates_presence_of :last_name, :first_name, :middle_name, :birth_date, :relationship, :civil_status, :gender
  belongs_to :member
  has_one :dependent_coverage

  def to_s
    "#{last_name}" + ", " + "#{first_name}" + " " + "#{middle_name[0.1]}" + ". "
  end

  def full_name 
    "#{last_name.capitalize}" + ", " + "#{first_name.capitalize}" + " " + "#{middle_name[0.1]}" + ". "
  end

  def get_formatted_dbday
    bday = birth_date.strftime("%m/%d/%Y")
  end

  def compute_dependent_benefit(coverage, val)
    mmbr_type = ""
    coverage.residency = (coverage.effectivity.year * 12 + coverage.effectivity.month) - (member.date_membership.year * 12 + member.date_membership.month)

    rlship = self.relationship
    
    case rlship
    when "Spouse"
      mmbr_type = 'spouse'
    when "Child"
      mmbr_type = 'child'
    when "Parent"
      mmbr_type = 'parent'
    end

    if val == "gp"
      
      g_prm = GroupPremium.where('? between residency_floor and residency_ceiling', coverage.residency)
      group_premium = g_prm.find_by(member_type: "#{mmbr_type}", term: coverage.term).premium unless g_prm.nil?
      
      return group_premium
    
    else

      g_bnft = GroupBenefit.where('? between residency_floor and residency_ceiling', coverage.residency)
      group_benefit_id = g_bnft.find_by(member_type: "#{mmbr_type}").id
      
      return group_benefit_id

    end
  end

  def get_dependent_group_benefit
    #return dependent.dependent_coverage.group_benefit.life
  end

  def is_dep_age_valid
        
    age = ((Date.today - self.birth_date.to_date) / 365).round
    rel = self.relationship

    #raise "error"
    
    if ["spouse", "parent"].include?(rel.downcase) && (18..65).include?(age)
      return true
    elsif ["child", "sibling"].include?(rel.downcase) && (3..21).include?(age)
      return true
    else
      return false
    end

  end

  def get_age(effectivity)
    ((effectivity - self.birth_date.to_date) / 365).round
  end

  def current_age
    ((Date.today - self.birth_date.to_date) / 365).round
  end


end
