class AddFbIdentifierToStatements < ActiveRecord::Migration[5.1]
  def change
    add_column :statements, :fb_identifier, :string
  end
end
