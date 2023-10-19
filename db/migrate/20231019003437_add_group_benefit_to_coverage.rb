class AddGroupBenefitToCoverage < ActiveRecord::Migration[7.0]
  def change
    add_reference :coverages, :group_benefit, foreign_key: false
    add_column :coverages, :dependent_premium, :decimal, precision: 10, scale: 2
  end
end
