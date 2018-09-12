class AddPositionAndTermNamesToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :position_held_name, :string
    add_column :pages, :parliamentary_term_name, :string
  end
end
