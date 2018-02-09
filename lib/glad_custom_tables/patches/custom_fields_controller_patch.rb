module GladCustomTables
  module Patches
    module CustomFieldsControllerPatch
      def self.included(base)
        #base.send(:include, InstanceMethods)

        base.class_eval do


          private

          def require_admin
          #TODO create new permissions
          end

        end
      end

      module InstanceMethods

      end
    end
  end
end

unless CustomFieldsController.included_modules.include?(GladCustomTables::Patches::CustomFieldsControllerPatch)
  CustomFieldsController.send(:include, GladCustomTables::Patches::CustomFieldsControllerPatch)
end