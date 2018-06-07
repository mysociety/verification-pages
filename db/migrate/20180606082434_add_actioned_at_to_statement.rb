class AddActionedAtToStatement < ActiveRecord::Migration[5.1]
  def change
    add_column :statements, :actioned_at, :datetime, null: true
  end
end
