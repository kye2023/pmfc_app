class CreateDependentCoverages < ActiveRecord::Migration[7.0]
  def change
    create_table :dependent_coverages do |t|
      t.references :coverage#, null: false, foreign_key: true
      t.references :dependent#, null: false, foreign_key: true
      t.references :member#, null: false, foreign_key: true
      t.references :group_benefit#, null: false, foreign_key: true
      t.references :batch#, null: false, foreign_key: true
      t.decimal :premium, precision: 10, scale:2

      t.timestamps
    end
  end
end
