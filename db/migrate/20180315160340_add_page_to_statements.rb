class AddPageToStatements < ActiveRecord::Migration[5.1]
  def up
    add_reference :statements, :page, foreign_key: true
    execute <<~SQL
      UPDATE statements s
      SET page_id = p.id
      FROM pages p
      WHERE p.parliamentary_term_item = s.parliamentary_term_item;
    SQL
  end

  def down
    remove_reference :statements, :page
  end
end
