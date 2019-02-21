class ChangePageCountryIdNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :pages, :country_id, from: false, to: true
  end
end
