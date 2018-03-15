class AllowNullParliamentaryTerms < ActiveRecord::Migration[5.1]
  def change
    change_column_null :pages, :parliamentary_term_item, true
    change_column_null :statements, :parliamentary_term_item, true
  end
end
