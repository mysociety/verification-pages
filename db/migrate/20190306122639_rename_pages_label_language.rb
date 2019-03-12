class RenamePagesLabelLanguage < ActiveRecord::Migration[5.2]
  def change
    rename_column :pages, :new_item_label_language, :csv_source_language
  end
end
