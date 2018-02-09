class AddCustomTableToQuery < ActiveRecord::Migration
  def change
    add_column :queries, :custom_table_id, :integer, null: true
  end
end
