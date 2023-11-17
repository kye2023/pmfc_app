class AddGracePeriodToCoverage < ActiveRecord::Migration[7.0]
  def change
    add_column :coverages, :grace_period, :integer 
    add_column :members, :suffix, :string
    add_column :dependents, :suffix, :string
  end
end
