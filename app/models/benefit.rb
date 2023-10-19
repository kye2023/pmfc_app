class Benefit < ApplicationRecord
  validates_presence_of :name, reject_if: :all_blank
end
