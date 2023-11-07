class DependentCoverage < ApplicationRecord
  belongs_to :coverage
  belongs_to :dependent
  belongs_to :member
  belongs_to :group_benefit
  belongs_to :batch, optional: true

  # def self.dep_premium
  #   premium = DependentCoverage.premium
  # end

end
