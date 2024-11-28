class AddPlanToCoverages < ActiveRecord::Migration[7.0]
  def change
    add_column :coverages, :plan_lppi, :boolean, default: true
    add_column :coverages, :plan_sgyrt, :boolean, default: true
    add_column :branches, :age_1865, :decimal, precision: 10, scale: 2
    add_column :branches, :age_6670b, :decimal, precision: 10, scale: 2
    add_column :branches, :age_6670a, :decimal, precision: 10, scale: 2
    add_column :branches, :age_7175b, :decimal, precision: 10, scale: 2
    add_column :branches, :age_7175a, :decimal, precision: 10, scale: 2
    add_column :branches, :age_7680b, :decimal, precision: 10, scale: 2
    add_column :branches, :age_7680a, :decimal, precision: 10, scale: 2
    add_column :branches, :res_0119, :decimal, precision: 10, scale: 2
    add_column :branches, :res_120a, :decimal, precision: 10, scale: 2
  end
end
