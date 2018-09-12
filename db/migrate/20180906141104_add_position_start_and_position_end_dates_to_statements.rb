class AddPositionStartAndPositionEndDatesToStatements < ActiveRecord::Migration[5.2]
  def change
    add_column :statements, :position_start, :date
    add_column :statements, :position_end, :date
  end
end
