class CreateCoverages < ActiveRecord::Migration[7.0]
  def change
    create_table :coverages do |t|
      t.string :batch_id
      t.string :member_id
      t.string :loan_certificate
      t.integer :age
      t.date :effectivity
      t.date :expiry
      t.integer :term
      t.string :status
      t.string :lppi_gross_premium
      t.string :group_certificate
      t.string :residency
      t.integer :group_coverage
      t.integer :group_premium

      t.timestamps
    end
  end
end
