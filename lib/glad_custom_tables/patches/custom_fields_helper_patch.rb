module GladCustomTables
  module Patches

    module CustomFieldsHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :show_value, :glad_custom_tables
        end
      end

      module InstanceMethods
        def show_value_with_glad_custom_tables(custom_value, html=true)
          return '' unless custom_value
          case custom_value.custom_field.field_format
          when 'belongs_to'
            if custom_value.custom_entity_id && html
              link_to custom_value.value, custom_entity_path(custom_value.custom_entity_id)
            else
              custom_value.value
            end
          when 'bool'
            if custom_value.true?
              l(:general_text_No)
            else
              l(:general_text_Yes)
            end
          when 'date'
            if custom_value.value.present?
              Date.parse(custom_value.value).strftime(Setting.date_format)
            else
              '---'
            end
          else
            format_object(custom_value.value, html)
          end
        end
      end
    end

  end
end

unless CustomFieldsHelper.included_modules.include?(GladCustomTables::Patches::CustomFieldsHelperPatch)
  CustomFieldsHelper.send(:include, GladCustomTables::Patches::CustomFieldsHelperPatch)
end
