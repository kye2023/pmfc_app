class CreatePremiumRates < ActiveRecord::Migration[7.0]
  def change
    create_table :premium_rates do |t|
      t.string :batch_id
      t.integer :premium

      t.timestamps
    end
  end
end
