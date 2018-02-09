# Patches
require 'glad_custom_tables/patches/custom_field_patch'
require 'glad_custom_tables/patches/custom_value_patch'
require 'glad_custom_tables/patches/journals_controller_patch'
require 'glad_custom_tables/patches/custom_fields_controller_patch'
require 'glad_custom_tables/patches/queries_controller_patch'
require 'glad_custom_tables/patches/custom_fields_helper_patch'
require 'glad_custom_tables/patches/custom_field_value_patch'
require 'glad_custom_tables/patches/redmine_field_format_patch'

# Table field formats
require_dependency 'glad_custom_tables/table_fields/format/belongs_to'
#CustomValue.joins(:custom_field).where('custom_fields.field_format = "belongs_to"').each {|value| value.update_attributes(custom_entity_id: value.value, value: value.custom_entity.name)}
