module CustomTables
  module Patches
    module UserFormatPatch
      def possible_values_records(custom_field, object=nil)
        if custom_field.is_a? CustomEntityCustomField
          User.active
        else
          super
        end
      end
    end
  end
end

Redmine::FieldFormat::UserFormat.send(:prepend, CustomTables::Patches::UserFormatPatch)
