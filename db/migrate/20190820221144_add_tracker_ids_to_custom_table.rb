class AddTrackerIdsToCustomTable < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_tables_trackers, id: false do |t|
      t.belongs_to :custom_table
      t.belongs_to :tracker
    end

    create_table :custom_tables_roles, id: false do |t|
      t.belongs_to :custom_table
      t.belongs_to :role
    end

    add_column :custom_tables, :description, :text
    add_column :custom_tables, :visible, :boolean, null: false, default: true
  end
end
