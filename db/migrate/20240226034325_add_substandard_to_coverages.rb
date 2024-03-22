class AddSubstandardToCoverages < ActiveRecord::Migration[7.0]
  def change
    add_column :coverages, :substandard_rate, :decimal, precision: 10, scale: 2
  end
end
