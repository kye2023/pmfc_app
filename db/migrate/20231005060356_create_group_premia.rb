class CreateGroupPremia < ActiveRecord::Migration[7.0]
  def change
    create_table :group_premia do |t|
      t.string :residency_from
      t.string :residency_to
      t.date :term_coverage
      t.integer :amount_premium
      t.string :relationship

      t.timestamps
    end
  end
end
