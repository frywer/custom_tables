class AddInternalNameToCustomTables < ActiveRecord::Migration[4.2]
  def change
    add_column :custom_tables, :type, :string, null: true
    add_column :custom_entities, :type, :string, null: true
  end
end
