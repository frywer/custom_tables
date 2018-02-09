class AddInternalNameToCustomTables < ActiveRecord::Migration
  def change
    #add_column :custom_tables, :internal_name, :string, null: true
    add_column :custom_tables, :type, :string, null: true
    add_column :custom_entities, :type, :string, null: true
    #CustomTable.find_by(name: 'Guest').update_columns(type: 'CustomTables::Guest')
    #CustomTable.find_by(name: 'Guest').custom_entities.each {|cg| cg.update_columns(type: 'CustomEntities::Guest')}
  end
end
