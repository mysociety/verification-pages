class AddArchivedToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :archived, :boolean, null: false, default: false
  end
end
