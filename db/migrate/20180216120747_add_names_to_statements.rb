class AddNamesToStatements < ActiveRecord::Migration[5.1]
  def change
    add_column :statements, :person_name, :string
    add_column :statements, :parliamentary_group_name, :string
    add_column :statements, :electoral_district_name, :string
  end
end
