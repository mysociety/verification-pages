class IncreaseClassifierVersionDefault < ActiveRecord::Migration[5.2]
  def up
    change_column :statements, :classifier_version, :integer, default: 2
  end

  def down
    change_column :statements, :classifier_version, :integer, default: 1
  end
end
