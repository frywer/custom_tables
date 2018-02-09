module GladCustomTables
  module Patches
    module CustomValuePatch
      def self.included(base)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          belongs_to :custom_entity

          after_update :ensure_belongs_to_values, if: -> {main_column? && customized.sub_entities.any?}

          def main_column?
            custom_field_id == custom_field.custom_table.main_custom_field.id
          end

          private

          def ensure_belongs_to_values
            CustomValue.where(custom_entity_id: customized_id, value: value_was).update_all(value: value)
          end

        end
      end
    end
  end
end

unless CustomValue.included_modules.include?(GladCustomTables::Patches::CustomValuePatch)
  CustomValue.send(:include, GladCustomTables::Patches::CustomValuePatch)
end