class AddCountryIdToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :country_id, :bigint
    add_index :pages, :country_id
  end
end
