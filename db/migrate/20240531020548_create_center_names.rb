class CreateCenterNames < ActiveRecord::Migration[7.0]
  def change
    create_table :center_names do |t|
      t.text :description

      t.timestamps
    end
  end
end
