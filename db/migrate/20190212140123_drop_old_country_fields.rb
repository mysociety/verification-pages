class DropOldCountryFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :countries, :description_en, :string
    remove_column :countries, :label_lang, :string
  end
end
