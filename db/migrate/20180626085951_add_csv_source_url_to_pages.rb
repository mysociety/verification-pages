class AddCsvSourceUrlToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :csv_source_url, :string, null: false, default: ''
  end
end
