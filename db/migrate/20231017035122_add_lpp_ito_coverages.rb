class AddLppItoCoverages < ActiveRecord::Migration[7.0]
  def change
    add_column :coverages, :loan_coverage, :decimal, precision: 10, scale: 2
    add_column :coverages, :rate, :decimal, precision: 10, scale: 2
  end
end
