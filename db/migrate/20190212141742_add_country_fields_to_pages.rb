class AddCountryFieldsToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :country_item, :string
    add_column :pages, :country_name, :string
    add_column :pages, :country_code, :string
  end
end
