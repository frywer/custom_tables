class AddExternalNameToCustomField < ActiveRecord::Migration[4.2]
  def change
    add_column :custom_fields, :external_name, :string, null: true
  end
end
