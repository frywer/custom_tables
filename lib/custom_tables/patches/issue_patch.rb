module CustomTables
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do

          has_many :custom_entities

        end
      end
    end
  end
end

Issue.send(:include, CustomTables::Patches::IssuePatch)