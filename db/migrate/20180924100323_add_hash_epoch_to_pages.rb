class AddHashEpochToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :hash_epoch, :integer, default: 1
  end
end
