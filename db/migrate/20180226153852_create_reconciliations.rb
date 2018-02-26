class CreateReconciliations < ActiveRecord::Migration[5.1]
  def change
    create_table :reconciliations do |t|
      t.references :statement, foreign_key: true
      t.string :item
      t.string :user

      t.timestamps
    end
  end
end
