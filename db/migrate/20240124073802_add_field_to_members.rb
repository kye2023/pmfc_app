class AddFieldToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :health_declaration, :string
  end
end
