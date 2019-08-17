class AddSubtablesToCustomTables < ActiveRecord::Migration[4.2]
  def change
    add_column :custom_tables, :parent_id, :integer, null: true, :index => true
    add_column :custom_tables, :lft, :integer, null: false, :index => true
    add_column :custom_tables, :rgt, :integer, null: false, :index => true

    add_column :custom_tables, :depth, :integer, null: false, default: 0
    add_column :custom_tables, :children_count, :integer, null: false, default: 0
  end
end
