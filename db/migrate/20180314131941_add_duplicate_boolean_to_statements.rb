class AddDuplicateBooleanToStatements < ActiveRecord::Migration[5.1]
  def change
    add_column :statements, :duplicate, :boolean, default: false
  end
end
