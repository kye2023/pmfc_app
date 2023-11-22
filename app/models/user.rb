class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # belongs_to :user_detail, optional: true
  has_one :user_detail
  # accepts_nested_attributes_for :user_detail
end
