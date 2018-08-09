class ChangePageReferenceUrlLength < ActiveRecord::Migration[5.2]
  def change
    change_column :pages, :reference_url, :string, limit: 2000
  end
end
