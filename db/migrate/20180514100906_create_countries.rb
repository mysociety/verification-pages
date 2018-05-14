class CreateCountries < ActiveRecord::Migration[5.1]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :code
      t.string :description_en
      t.string :label_lang
      t.string :wikidata_id

      t.timestamps
    end
  end
end
