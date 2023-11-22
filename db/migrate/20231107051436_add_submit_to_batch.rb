class AddSubmitToBatch < ActiveRecord::Migration[7.0]
  def change
    add_column :batches, :submit, :boolean, default: false
  end
end
