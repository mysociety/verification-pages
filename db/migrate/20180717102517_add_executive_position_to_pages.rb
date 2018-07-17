class AddExecutivePositionToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :executive_position, :boolean, null: false, default: false
  end
end
