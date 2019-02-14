class IncreasePageHasEpoch3 < ActiveRecord::Migration[5.2]
  def up
    change_column :pages, :hash_epoch, :integer, default: 3
  end

  def down
    change_column :pages, :hash_epoch, :integer, default: 2
  end
end
