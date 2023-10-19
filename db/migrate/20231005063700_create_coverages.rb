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
      t.decimal :loan_premium, precision: 10, scale: 2
      t.decimal :group_premium, precision: 10, scale: 2
      t.string :group_certificate
      t.string :residency
      

      t.timestamps
    end
  end
end
