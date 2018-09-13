class DropRequireParliamentaryGroupFromPages < ActiveRecord::Migration[5.2]
  def change
    remove_column :pages, :require_parliamentary_group, :boolean, default: false
  end
end
