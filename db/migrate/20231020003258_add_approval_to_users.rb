class AddApprovalToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :approved, :boolean, default: false
    # add_column :users, :admin, :boolean, default: false
    # add_column :users, :admin, :boolean
    # add_reference :users, :user_detail, foreign_key: false
    # add_reference :users, :branch, foreign_key: false
  end
end
