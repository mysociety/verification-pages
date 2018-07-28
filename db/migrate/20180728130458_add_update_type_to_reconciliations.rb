class AddUpdateTypeToReconciliations < ActiveRecord::Migration[5.2]
  def change
    add_column :reconciliations, :update_type, :integer, default: 0
  end
end
