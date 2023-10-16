class Dependent < ApplicationRecord
  validates_presence_of :last_name, :first_name, :middle_name, :birth_date
  belongs_to :member
end
