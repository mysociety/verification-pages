class AddNewItemLabelLanguageToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :new_item_label_language, :string
  end
end
