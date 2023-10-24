class Dependent < ApplicationRecord
  validates_presence_of :last_name, :first_name, :middle_name, :birth_date
  belongs_to :member
  has_one :dependent_coverage

  def to_s
    "#{last_name}" + ", " + "#{first_name}" + " " + "#{middle_name[0.1]}" + ". "
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
      gp = GroupPremium.where('? between residency_floor and residency_ceiling', coverage.residency)
      group_premium = gp.find_by(member_type: "#{mmbr_type}", term: coverage.term).premium unless gp.nil?
      return group_premium
    else
      gb = GroupBenefit.where('? between residency_floor and residency_ceiling', coverage.residency)
      group_benefit_id = gb.find_by(member_type: "#{mmbr_type}").id
      return group_benefit_id
    end
  end

  def get_dependent_group_benefit
    #return dependent.dependent_coverage.group_benefit.life
  end

end
