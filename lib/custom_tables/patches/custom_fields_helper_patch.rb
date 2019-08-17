module CustomTables
  module Patches

    module CustomFieldsHelperPatch
      def self.included(base) # :nodoc:
        base.class_eval do


        end
      end

      def show_value(custom_value, html=true)
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

CustomFieldsHelper.send(:prepend, CustomTables::Patches::CustomFieldsHelperPatch)

