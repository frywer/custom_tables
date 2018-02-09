module GladCustomTables
  module Patches
    module CustomFieldValuePatch
      def self.included(base)
        base.class_eval do
          attr_accessor :custom_entity_id
        end
      end
    end
  end
end

unless CustomFieldValue.included_modules.include?(GladCustomTables::Patches::CustomFieldValuePatch)
  CustomFieldValue.send(:include, GladCustomTables::Patches::CustomFieldValuePatch)
end