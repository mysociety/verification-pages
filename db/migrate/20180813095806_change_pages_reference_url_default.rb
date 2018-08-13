class ChangePagesReferenceUrlDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :pages, :reference_url, from: nil, to: ''
  end
end
