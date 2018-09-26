module CustomTables
  module Patches
    module CustomFieldPatch
      def self.included(base)
        base.class_eval do

          validates_uniqueness_of :external_name, scope: :custom_table_id

          belongs_to :custom_table
          belongs_to :parent_table, class_name: 'CustomTable'

          safe_attributes 'external_name'

          before_create :generate_external_name

          private

          def generate_external_name
            self.external_name = name.downcase.gsub(/[^0-9A-Za-z]/, '_')
          end

        end
      end
    end
  end
end

CustomField.send(:include, CustomTables::Patches::CustomFieldPatch)
