class DependentCoverage < ApplicationRecord
  belongs_to :coverage
  belongs_to :dependent
  belongs_to :member
  belongs_to :group_benefit


end
