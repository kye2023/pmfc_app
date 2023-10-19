class CreateGroupPremia < ActiveRecord::Migration[7.0]
  def change
    create_table :group_premia do |t|
      t.string :member_type
      t.integer :term
      t.integer :residency_floor
      t.integer :residency_ceiling
      t.decimal :premium, precision: 10, scale: 2

      t.timestamps
    end
  end
end
