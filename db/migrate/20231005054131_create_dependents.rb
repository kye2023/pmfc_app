class CreateDependents < ActiveRecord::Migration[7.0]
  def change
    create_table :dependents do |t|
      t.string :member_id
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.date :birth_date
      t.string :civil_status
      t.string :gender
      t.string :mobile_no
      t.string :email
      t.string :relationship

      t.timestamps
    end
  end
end
