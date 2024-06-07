class AddColumnCenterToCoverage < ActiveRecord::Migration[7.0]
  def change
    add_reference :coverages, :center_name#, null: false, foreign_key: true
  end
end
