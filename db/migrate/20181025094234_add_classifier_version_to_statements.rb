class AddClassifierVersionToStatements < ActiveRecord::Migration[5.2]
  def change
    add_column :statements, :classifier_version, :integer, default: 1
  end
end
