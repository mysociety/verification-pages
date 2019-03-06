class AddPartyAndDistrictFieldsToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :new_party_description_en, :string
    add_column :pages, :new_party_instance_of_item, :string
    add_column :pages, :new_party_instance_of_name, :string
    add_column :pages, :new_district_description_en, :string
    add_column :pages, :new_district_instance_of_item, :string
    add_column :pages, :new_district_instance_of_name, :string
  end
end
