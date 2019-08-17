module CustomTables
  module Patches
    module QueriesControllerPatch

      def redirect_to_custom_entity_query(options)
        redirect_to custom_table_path(params[:custom_table_id])# || @query.custom_table_id)
      end

      # def update_query_from_params
      #   @query.custom_table_id = params[:custom_table_id] if params[:custom_table_id]
      #   super
      # end

      def self.prepended(base)
        base.class_eval do
        end
      end
    end
  end
end

QueriesController.send(:prepend, CustomTables::Patches::QueriesControllerPatch)
