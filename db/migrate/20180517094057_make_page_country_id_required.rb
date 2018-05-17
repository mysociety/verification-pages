class MakePageCountryIdRequired < ActiveRecord::Migration[5.1]
  def change
    change_column_null :pages, :country_id, false
  end
end
