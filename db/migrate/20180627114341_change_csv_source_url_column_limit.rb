class ChangeCsvSourceUrlColumnLimit < ActiveRecord::Migration[5.1]
  def up
    change_column :pages, :csv_source_url, :string, limit: 2000
  end

  def down
    change_column :pages, :csv_source_url, :string, limit: 255
  end
end
