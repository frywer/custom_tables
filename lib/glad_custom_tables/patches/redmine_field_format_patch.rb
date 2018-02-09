module GladCustomTables
  module Patches
    module RedmineFieldFormatPatch
      #base.send(:include, InstanceMethods)
      def self.included(base)
        base.class_eval do

          def edit_tag(view, tag_id, tag_name, custom_value, options={})
            view.date_field_tag(tag_name, custom_value.value, options.merge(id: tag_id, size: 10, placeholder: "YYYY-MM-DD"))
          end
        end
      end

      module InstanceMethods
      end
    end
  end
end

Redmine::FieldFormat::DateFormat.send(:include, GladCustomTables::Patches::RedmineFieldFormatPatch)