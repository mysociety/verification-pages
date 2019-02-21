class DropCountries < ActiveRecord::Migration[5.2]
  def up
    remove_column :pages, :country_id

    drop_table :countries
  end

  def down
    create_table :countries do |t|
      t.string :name
      t.string :code
      t.string :wikidata_id
      t.timestamps
    end

    add_column :pages, :country_id, :bigint, null: true
    add_index :pages, :country_id
  end
end
