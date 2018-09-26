module CustomTables
  module Patches
    module QueriesControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do

          alias_method_chain :update_query_from_params, :custom_tables

          def redirect_to_custom_entity_query(options)
            redirect_to custom_table_path(params[:custom_table_id] || @query.custom_table_id)
          end

        end
      end


      module InstanceMethods

        def update_query_from_params_with_custom_tables
          @query.custom_table_id = params[:custom_table_id] if params[:custom_table_id]
          update_query_from_params_without_custom_tables
        end

      end
    end
  end
end

QueriesController.send(:include, CustomTables::Patches::QueriesControllerPatch)
