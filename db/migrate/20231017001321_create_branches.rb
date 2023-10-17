class CreateBranches < ActiveRecord::Migration[7.0]
  def change
    create_table :branches do |t|
      t.string :name
      t.text :description
      t.string :address
      t.string :contact_no
      t.string :email

      t.timestamps
    end
    add_reference :batches, :branch
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
