module CustomTables
  module Patches
    module ProjectPatch
      def self.included(base)
        base.class_eval do

          has_and_belongs_to_many :custom_tables

          # Returns a scope of all custom tables enabled for project issues
          # (explicitly associated custom tables and custom tables enabled for all projects)
          def all_issue_custom_tables(issue)
            @custom_tables ||= CustomTable.
                joins(:trackers).
                visible.
                sorted.
                where("custom_tables.is_for_all = ? OR custom_tables.id IN (?)", true, custom_table_ids).
                where(trackers: {id: issue.tracker})
          end

        end
      end
    end
  end
end

Project.send(:include, CustomTables::Patches::ProjectPatch)