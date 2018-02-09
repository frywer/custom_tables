class AddCustomTableToCustomFields < ActiveRecord::Migration
  def change
    add_reference :custom_fields, :custom_table, default: nil, index: true
  end
end
