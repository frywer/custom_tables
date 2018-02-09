class AddExternalNameToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :external_name, :string, null: true
  end
end
