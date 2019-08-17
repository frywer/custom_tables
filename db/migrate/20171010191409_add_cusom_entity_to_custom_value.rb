class AddCusomEntityToCustomValue < ActiveRecord::Migration[4.2]
  def change
    add_reference :custom_values, :custom_entity, index: true
  end
end
