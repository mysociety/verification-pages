class AllowNullStatementItems < ActiveRecord::Migration[5.1]
  def change
    change_column_null :statements, :person_item, true
    change_column_null :statements, :electoral_district_item, true
    change_column_null :statements, :parliamentary_group_item, true
  end
end
