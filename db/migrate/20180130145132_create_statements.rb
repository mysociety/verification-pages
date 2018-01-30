class CreateStatements < ActiveRecord::Migration[5.1]
  def change
    create_table :statements do |t|
      t.string :transaction_id
      t.string :person_item, null: false
      t.string :person_revision
      t.string :statement_uuid
      t.string :parliamentary_group_item
      t.string :electoral_district_item, null: false
      t.string :parliamentary_term_item, null: false

      t.timestamps
    end
  end
end
