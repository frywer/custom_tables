class AddCusomEntityToCustomValue < ActiveRecord::Migration
  def change
    add_reference :custom_values, :custom_entity, index: true
    # CustomValue.joins(:custom_field).where('custom_fields.field_format = "belongs_to"').each {|value| value.update_attributes(custom_entity_id: value.value)}
    # CustomValue.joins(:custom_field).where('custom_fields.field_format = "belongs_to"').where.not(value: '').each {|value| value.update_attributes(value: value.custom_entity.name)}
  end
end
