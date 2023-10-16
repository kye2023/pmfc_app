class Benefit < ApplicationRecord
  validates_presence_of :name, :description, reject_if: :all_blank, allow_destroy: true
end
