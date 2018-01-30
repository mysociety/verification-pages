class CreatePages < ActiveRecord::Migration[5.1]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.string :position_held_item, null: false
      t.string :parliamentary_term_item, null: false
      t.string :reference_url, null: false
      t.boolean :require_parliamentary_group, default: false

      t.timestamps
    end
  end
end
