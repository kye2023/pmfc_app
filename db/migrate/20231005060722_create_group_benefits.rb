class CreateGroupBenefits < ActiveRecord::Migration[7.0]
  def change
    create_table :group_benefits do |t|
      t.string :benefit_id
      t.string :residency_from
      t.string :residency_to
      t.string :relationship
      t.integer :amount_benefit

      t.timestamps
    end
  end
end
