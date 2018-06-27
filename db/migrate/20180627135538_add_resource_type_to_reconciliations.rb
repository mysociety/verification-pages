class AddResourceTypeToReconciliations < ActiveRecord::Migration[5.1]
  def change
    add_column :reconciliations, :resource_type, :string
  end
end
