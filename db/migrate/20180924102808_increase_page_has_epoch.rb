class IncreasePageHasEpoch < ActiveRecord::Migration[5.2]
  def up
    change_column :pages, :hash_epoch, :integer, default: 2
  end

  def down
    change_column :pages, :hash_epoch, :integer, default: 1
  end
end
