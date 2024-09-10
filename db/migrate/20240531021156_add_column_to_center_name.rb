class AddColumnToCenterName < ActiveRecord::Migration[7.0]
  def change
    add_reference :center_names, :branch, null: false, foreign_key: true
    #add_reference :coverages, :center_id, null: false, foreign_key: true
  end
end
