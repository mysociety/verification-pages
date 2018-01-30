class CreateResults < ActiveRecord::Migration[5.1]
  def change
    create_table :results do |t|
      t.references :statement, null: false
      t.integer :status, null: false
      t.string :user, null: false

      t.timestamps
    end
  end
end
