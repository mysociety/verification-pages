class RemoveDefaultFromPagesCsvSourceUrl < ActiveRecord::Migration[5.1]
  def change
    change_column_default :pages, :csv_source_url, nil
  end
end
