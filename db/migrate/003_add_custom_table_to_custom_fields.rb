class AddCustomTableToCustomFields < ActiveRecord::Migration[4.2]
  def change
    add_reference :custom_fields, :custom_table, default: nil, index: true
  end
end
