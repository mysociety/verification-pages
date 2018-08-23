class AddReferenceUrlToVerifications < ActiveRecord::Migration[5.2]
  def change
    add_column :verifications, :reference_url, :string, limit: 2000
  end
end
