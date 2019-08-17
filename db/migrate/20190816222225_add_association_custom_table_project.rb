class AddAssociationCustomTableProject < ActiveRecord::Migration[5.2]
  def change
    remove_column :custom_tables, :project_id, :integer
    create_table :custom_tables_projects, id: false do |t|
      t.belongs_to :custom_table
      t.belongs_to :project
    end
    add_column :custom_tables, :is_for_all, :boolean
    add_reference :custom_entities, :issue
  end
end
