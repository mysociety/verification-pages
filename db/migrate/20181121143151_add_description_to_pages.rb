class AddDescriptionToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :new_item_description_en, :string
  end
end
