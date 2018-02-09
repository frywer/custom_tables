module GladCustomTables
  module Patches
    module CustomFieldPatch
      def self.included(base)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          clear_validators!
          validates_presence_of :name, :field_format
          validates_uniqueness_of :name, scope: :type, conditions: -> { where.not(type: 'CustomEntityCustomField') }
          validates_uniqueness_of :name, scope: :custom_table_id
          validates_length_of :name, :maximum => 30
          validates_length_of :regexp, maximum: 255
          validates_inclusion_of :field_format, :in => Proc.new { Redmine::FieldFormat.available_formats }
          validate :validate_custom_field

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

unless CustomField.included_modules.include?(GladCustomTables::Patches::CustomFieldPatch)
  CustomField.send(:include, GladCustomTables::Patches::CustomFieldPatch)
end