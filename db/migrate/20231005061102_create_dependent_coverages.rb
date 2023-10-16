class CreateDependentCoverages < ActiveRecord::Migration[7.0]
  def change
    create_table :dependent_coverages do |t|
      t.string :coverage_id
      t.string :dependent_id
      t.string :member_id
      t.date :term
      t.string :residency
      t.integer :group_coverage
      t.integer :group_premium

      t.timestamps
    end
  end
end
