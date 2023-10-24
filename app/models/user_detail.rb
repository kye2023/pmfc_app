class UserDetail < ApplicationRecord
  validates_presence_of :last_name, :first_name
  belongs_to :user
  belongs_to :branch
  # has_one :user, dependent: :destroy
  accepts_nested_attributes_for :user
end
