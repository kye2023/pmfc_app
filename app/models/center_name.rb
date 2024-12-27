class CenterName < ApplicationRecord
  belongs_to :branch
  has_many :coverages
  validates_presence_of :description


  def self.get_cname_index(admin, query, current_user)
    if query.present?
      if admin == true
        where("description LIKE ?", "%#{query}%")
      else
        where(branch_id: current_user.user_detail.branch_id).where("description LIKE ?", "%#{query}%")
      end
    else
      if admin == true
        all
      else
        where(branch_id: current_user.user_detail.branch_id)
      end
    end
  end

end
