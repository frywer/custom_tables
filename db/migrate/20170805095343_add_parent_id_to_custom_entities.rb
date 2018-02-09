class AddParentIdToCustomEntities < ActiveRecord::Migration
  def change
    create_table :related_custom_entities, id: false do |t|
      t.integer :parent_entity_id
      t.integer :sub_entity_id
    end

    add_index :related_custom_entities, [:parent_entity_id, :sub_entity_id], unique: true, name: 'idx_sub_and_parent_entities'
    add_index :related_custom_entities, [:sub_entity_id, :parent_entity_id], unique: true, name: 'idx_parent_and_sub_entities'

    add_column :custom_tables, :settings, :text, null: true, length: 50.megabytes
    add_reference :custom_fields, :parent_table, default: nil, index: true, null: true
    #add_reference :custom_values, :custom_entity, default: nil, index: true, null: true
  end
end
