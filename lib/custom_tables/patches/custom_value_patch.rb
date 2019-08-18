module CustomTables
  module Patches
    module CustomValuePatch
      def self.included(base)
        base.class_eval do

          belongs_to :custom_entity

        end
      end
    end
  end
end

CustomValue.send(:include, CustomTables::Patches::CustomValuePatch)
