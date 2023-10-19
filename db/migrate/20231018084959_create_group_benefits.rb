class CreateGroupBenefits < ActiveRecord::Migration[7.0]
  def change
    create_table :group_benefits do |t|
      t.string :member_type
      t.integer :residency_floor
      t.integer :residency_ceiling
      t.decimal :life, precision: 12, scale: 2
      t.decimal :add, precision: 12, scale: 2
      t.decimal :burial, precision: 12, scale: 2

      t.timestamps
    end
  end
end
