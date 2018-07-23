class AddReferenceUrlTitleAndLanguageToPage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :reference_url_title, :string
    add_column :pages, :reference_url_language, :string
  end
end
