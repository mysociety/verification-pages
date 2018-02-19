class RenameResultsToVerifications < ActiveRecord::Migration[5.1]
  def up
    change_column :results, :status, 'bool USING CAST(status AS bool)'
    change_column_null :results, :status, true
    change_column_default :results, :status, false
    rename_table :results, :verifications
  end

  def down
    rename_table :verifications, :results
    change_column_default :results, :status, nil
    change_column_null :results, :status, false
    change_column :results, :status, 'integer USING CAST(status AS integer)'
  end
end
