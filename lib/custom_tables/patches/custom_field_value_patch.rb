module CustomTables
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

CustomFieldValue.send(:include, CustomTables::Patches::CustomFieldValuePatch)
