class AddRemovedFromSourceToStatements < ActiveRecord::Migration[5.2]
  def change
    add_column :statements, :removed_from_source, :boolean, default: false
  end
end
