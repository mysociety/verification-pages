class AddErrorReportedAndReportedAtToStatements < ActiveRecord::Migration[5.1]
  def change
    add_column :statements, :error_reported, :string
    add_column :statements, :reported_at, :timestamp
  end
end
