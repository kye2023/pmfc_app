class CreateUserDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :user_details do |t|
      t.references :user#, null: false, foreign_key: true
      t.references :branch#, null: false, foreign_key: true
      t.string :last_name
      t.string :first_name
      t.string :middle_initial
      t.string :gender
      t.string :contact_no
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
