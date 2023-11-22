class AddBranchToMember < ActiveRecord::Migration[7.0]
  def change
    add_reference :members, :branch#, null: false, foreign_key: true
  end
end
