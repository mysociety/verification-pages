class AddNewNameToVerification < ActiveRecord::Migration[5.1]
  def change
    add_column :verifications, :new_name, :string, null: true, default: nil
  end
end
