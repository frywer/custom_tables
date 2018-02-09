module GladCustomTables
  module TableFields
    module Format

      class BelongsTo < Redmine::FieldFormat::List
        add 'belongs_to'
        self.form_partial = 'custom_fields/formats/belongs_to'

        def possible_values_options(custom_field, object=nil)
          if custom_field.belongs_to_format?
            custom_field.parent_table.main_custom_field.custom_values.pluck(:value, :customized_id)
          else
            super
          end
        end

        def select_edit_tag(view, tag_id, tag_name, custom_value, options={})
          blank_option = ''.html_safe
          unless custom_value.custom_field.multiple?
            if custom_value.custom_field.is_required?
              unless custom_value.custom_field.default_value.present?
                blank_option = view.content_tag('option', "--- #{l(:actionview_instancetag_blank_option)} ---", :value => '')
              end
            else
              blank_option = view.content_tag('option', '&nbsp;'.html_safe, :value => '')
            end
          end
          options_tags = blank_option + view.options_for_select(possible_custom_value_options(custom_value), custom_value.custom_entity_id)
          s = view.select_tag(tag_name, options_tags, options.merge(:id => tag_id, :multiple => custom_value.custom_field.multiple?))
          if custom_value.custom_field.multiple?
            s << view.hidden_field_tag(tag_name, '')
          end
          s
        end

      end

    end
  end
end
