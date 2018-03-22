class DropStatementTerms < ActiveRecord::Migration[5.1]
  def change
    remove_column :statements, :parliamentary_term_item, :string
  end
end
