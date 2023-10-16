class Members < ActiveRecord::Migration[7.0]
  def change
    remove_column :members, :member_id, :string
  end
end
