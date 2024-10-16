class BranchAddColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :branches, :service_fee, :decimal, precision: 10, scale: 2
    add_column :members, :plan_lppi, :boolean, default: true
    add_column :members, :plan_sgyrt, :boolean, default: true
  end
end
